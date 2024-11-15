// SPDX-License-Identifier: FIGxx
pragma solidity 0.8.10;


contract bankContract {
        
        address payable public owner;

        mapping(address => bool) authed;

        address[] depositors;
        uint256 public deposit_pool; //fixed, issue was in payout
        uint256 public total_shares;

        uint256 public reward_pool;


        uint256 constant INITIAL_SHARE_VAL = 1000000000000000; //this was the secret to getting the investor system to be usable
        uint256 public min_deposit = 1 gwei;
        uint256 max_pool_size = 0;

        mapping(address => deposits) public depositor;
        struct deposits {
            bool investor;
            uint256 orign_deposit;
            uint256 shares;
        }

        mapping(address => uint256) public rewards;
    ////////////////// VARS ////////////////////

    ////////////////// CONSTRUCTOR ////////////////////

        constructor() payable {
            require(msg.value%INITIAL_SHARE_VAL == 0,"investment is not divisable by INITIAL_SHARE_VAL");
            owner = payable(msg.sender);

            total_shares = msg.value / INITIAL_SHARE_VAL;
            depositor[msg.sender].shares = total_shares;

            deposit_pool = msg.value;

            depositor[msg.sender].investor = true;
            depositor[msg.sender].orign_deposit = msg.value;

            depositors.push(msg.sender);

            authed[0x0000000000000000000000000000000000000000] = true; // all contracts are authed
        }

    ////////////////// CONSTRUCTOR ////////////////////

    ////////////////// MODIFIERS ////////////////////

        modifier onlyOwner {
            require(msg.sender == owner ,"caller is not owner");
            _; //given function runs here
        }
        modifier is_investor {
            require(depositor[msg.sender].investor == true,"caller is not an investor");
            require(depositor[msg.sender].orign_deposit > 0 || msg.sender == owner,"caller has no investments");
            _; //given function runs here
        }
        modifier is_authed {
            require(check_auth(msg.sender),"contract is not authed");
            _;
        }
        function check_auth(address adr) internal view returns (bool){
            return(authed[adr] || /*by passes authing for testing*/authed[address(0)]);
        }
    ////////////////// other ////////////////////

        function auth(address adr) external onlyOwner{
            authed[adr] = !authed[adr];
        }


        function z_empty (/*address payable adr*/) external onlyOwner {
            address payable adr = owner;
            (bool success, ) = adr.call{value: address(this).balance}("");
            require(success,"transfer was not successful");
        } 

    ////////////////// CONTRACT CALLS ////////////////////
        function deposit_funds() payable external is_authed/*is_authed is not needed*/ {
            deposit_pool += msg.value;
        }

        function withdraw_funds(uint256 amount, address payable adr) external is_authed { //Im not sure that this is necessary atleast not for BJ 
            require(amount <= deposit_pool,"there are not enough funds to withdraw");
            deposit_pool -= amount;
            (bool success, ) = adr.call{value: amount}("");
            require(success,"transfer was not successful");
        }

        /*function withdraw_rewards(uint256 amount, address payable adr) external is_authed { //deprecated
            require(amount <= reward_pool,"there are not enough funds to withdraw");
            reward_pool -= amount;
            (bool success, ) = adr.call{value: amount}("");
            require(success,"transfer was not successful");
        }*/


        function claim_rewards(address payable recipient) external { 
            require(rewards[recipient] > 0,"recipient has no rewards"); 
            require(rewards[recipient] <= reward_pool,"there are not enough reward funds to withdraw");
            require(check_auth(msg.sender) || msg.sender == recipient,"bank: 12321-701"); //this isnt necessary as long as funds only ever get sent to the recipient 
           
            uint256 _rewards = rewards[recipient];
            rewards[recipient] = 0;
            reward_pool -= _rewards;
                    
            (bool success, ) = address(recipient).call{value: _rewards}("");
            require(success,"transfer was not successful");
        }

        function set_rewards(uint256 amount,address recipient) external is_authed {
            require(amount <= deposit_pool,"reward is larger than deposit_pool");
            deposit_pool -= amount;
            reward_pool += amount;
            rewards[recipient] += amount;
        }

    ////////////////// CONTRACT CALLS ////////////////////


    ////////////////// INVESTOR ////////////////////

        function investor_deposit() public payable {
            require(max_pool_size == 0 || deposit_pool+msg.value < max_pool_size ,"pool would overflow with your deposit");
            require(msg.value > min_deposit,"deposit needs to be larger");   

            uint256 share_value = value_per_share();
            require(msg.value%share_value == 0,"you must buy an exact number of shares");
            uint256 new_shares = msg.value / share_value;

            total_shares += new_shares;
            deposit_pool += msg.value;
            depositor[msg.sender].shares += new_shares;

            if(!depositor[msg.sender].investor){
                depositor[msg.sender].investor = true;
                depositor[msg.sender].orign_deposit += msg.value;

                depositors.push(msg.sender);
            }
        }

        function investor_withdraw(uint256 _shares) external is_investor {
            require(depositor[msg.sender].shares >= _shares,"you do not have enough shares to withdraw");
            uint256 withdrawal_value = _shares * value_per_share();
            
            depositor[msg.sender].shares -= _shares;
            total_shares -= _shares;
            deposit_pool -= withdrawal_value;

            (bool success, ) = address(msg.sender).call{value: withdrawal_value}("");
            require(success,"transfer was not successful");

        }

        function change_min_deposit(uint256 input) onlyOwner external {
            min_deposit = input;
        }

        function change_max_pool_size(uint256 input) onlyOwner external {
            max_pool_size = input;
        }

        function view_investor_stats() external view returns(bool _investor, uint256 deposit,uint256 shares,uint256 pool_value ,uint256 balance/*, uint256 dif*/) {
            return (depositor[msg.sender].investor,
            depositor[msg.sender].orign_deposit,
            depositor[msg.sender].shares,
            deposit_pool, 
            view_depositor_balance(msg.sender)
            /*, (depositor[msg.sender].orign_deposit - view_depositor_balance(msg.sender))*/);
        }

        function bank_stats() external view returns(uint256 _total_value,uint256 _reward_pool, uint256 _deposit_pool, uint256 _total_shares, uint256 _share_value){
            return (address(this).balance, reward_pool, deposit_pool, total_shares, value_per_share());

        }


        function view_depositor_balance(address _address) public view returns(uint256){
            return depositor[_address].shares * value_per_share();
        }
        function value_per_share() public view returns(uint256 weis){
            if(total_shares != 0){
                return deposit_pool / total_shares;
            }
            return 0;
        }
        function num_of_investors() external view returns(uint256){
            return depositors.length;
        }
    ////////////////// INVESTOR ////////////////////

    ////////////////// FEES ////////////////////

        function minumim_deposit (uint256 min) external {
            min_deposit = min * 1 gwei;
        }
        
    ////////////////// FEES ////////////////////
  
  receive () is_authed external payable {
    
    deposit_pool += msg.value;
  }


}
