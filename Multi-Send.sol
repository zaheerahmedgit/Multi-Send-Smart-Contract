// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract MultiSend {
    address[] public users; //Array to store the addresses of users
    address public owner; //variable to store address of owner

    event UserAdded(address user); //event to emit when user added in the system
    event MultiTransfer(address sender, uint256[] indexes, uint256[] amounts); //event to emit when ether distributed to multiple addresses of users

	//modifier to restrict the access of contract to only owner of the contract
    modifier onlyOwner(){
        require(owner==msg.sender, "Caller is not owner");
        _;
    }

	//constructor to define that the msg.sender will be the owner
    constructor(){
        owner = msg.sender;
    }

	//function to add user in the system    
    function addUser(address _user) public onlyOwner{
        require(_user != address(0), "Invalid address");
        require(_user != msg.sender, "You can't send to yourself");
        for (uint256 i = 0; i < users.length; i++) {
            require(users[i] != _user, "User already added");
        }
        users.push(_user);

        emit UserAdded(_user);
    }

	//function to transfer ethers to the contract
    function sendEthToContract() public payable onlyOwner {
        require(msg.value > 0, "Amount to transfer must be greater than zero");
    }

	//function to transfer ethers to multiple addresses of users
    function multiTransfer(uint256[] memory index, uint256[] memory amount) public onlyOwner {
        require(index.length == amount.length, "Index and amount arrays must have the same length");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amount.length; i++) {
            totalAmount += amount[i];
        }
        
        require(totalAmount <= address(this).balance, "Not enough Ether in the contract");

        for (uint256 i = 0; i < index.length; i++) {
            require(index[i] < users.length, "Invalid index");
            require(amount[i] > 0, "Amount must be greater than zero");
            
            payable(users[index[i]]).transfer(amount[i]);
        }

        emit MultiTransfer(msg.sender, index, amount);
    }

	//function to check the balance of the contract
    function contractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
