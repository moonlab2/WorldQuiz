pragma solidity ^0.4.23;

import "./Answer.sol";

contract WQVault {
	address private owner;

	mapping (address => bool) spender;

	constructor (address _owner) public {
		owner = _owner;
		spender[owner] = true;
	}

	function () external payable {
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier onlySpender() {
		require(spender[msg.sender]);
		_;
	}

	function transferOwnership (address _newOwner) onlyOwner external {
		owner = _newOwner;
	}

	function registerSpender (address[] _spender) onlyOwner external {
		for(uint8 i = 0; i < _spender.length; i++) {
			spender[_spender[i]] = true;
		}
	}

	function deleteSpender (address _spender) onlyOwner external {
		spender[_spender] = false;
	}

	function transferTo(address _to, uint256 _amount) onlySpender external {
		_to.transfer(_amount);
	}


}
