// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimpleERC20 {
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function checkBalance(address addr) external view returns(uint256);
}

contract SimpleERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    string public name;
    string public symbol;

    event Transfer(address sender, address recipient, uint256 amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    function checkBalance(address addr) external view returns(uint256) {
        return balanceOf[addr];
    }
}