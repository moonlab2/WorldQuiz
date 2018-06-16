pragma solidity ^0.4.23;

import "./WQVault.sol";

contract Answer {
	address public quiz;
	WQVault vault;

	address public wqt;

	uint256 public gathered;
	uint8 public cap;

	uint256 public startTime;
	uint256 public endTime;

	bool public opened;

	mapping (address => uint256) public playedAmount;
	mapping (uint8 => address) public players;

	uint8 public totalPlayers;


	constructor (address _quiz, address _vault) public {
		quiz = _quiz;
		vault = WQVault(_vault);

		opened = false;

	}

	modifier fromQuizContract() {
		require(msg.sender == quiz);
		_;
	}

	function changeQuiz(address _quiz) fromQuizContract external {
		quiz = _quiz;
	}

	// for WQT
	function registerWQT(address _wqt) fromQuizContract external {
		wqt = _wqt;
	}

	function openAnswer(uint256 _start, uint256 _end, uint8 _cap) fromQuizContract external {
		require(!opened);

		startTime = _start;
		endTime = _end;
		cap = _cap;

		opened = true;
		gathered = 0;

		for(uint8 i = 0; i < totalPlayers; i++) {
			playedAmount[players[i]] = 0;
		}

		totalPlayers = 0;
	}

	function closeAnswer(bool _withToken) fromQuizContract external returns (bool){
		if(!opened)
			return false;

		quiz.transfer(gathered);

		// WQT
		// burn all token
		if(_withToken) {
			uint256 tokenGathered;
			tokenGathered = wqt.call(bytes4(keccak256("getBalaceOf(address)"), this));
			wqt.call(bytes4(keccak256("burn(uint256)")), tokenGathered);
		}

		opened = false;
	}

	function () external payable {
		require(startTime <= now && now <= endTime);
		require(cap > totalPlayers);
		require(opened);
		uint256 checkup;
		checkup = msg.value >= 10 ** 18 ? 10 ** 15 : msg.value / 1000;

		// check if the msg.sender is possible to receive
		vault.transferTo(msg.sender, checkup);

		if(playedAmount[msg.sender] == 0) {
			players[totalPlayers] = msg.sender;
			totalPlayers++;
		}
		playedAmount[msg.sender] += msg.value - checkup;
		gathered += msg.value;
	}
	
	function getAddress(uint8 _no) external view returns(address) {
		return players[_no];
	}

	function getAmount(uint8 _no) external view returns(uint256) {
		return playedAmount[players[_no]];
	}


	function getGathered() external view returns(uint256) {
		return gathered;
	}
	function getTotalPlayers() external view returns(uint8) {
		return totalPlayers;
	}
	function isOpen() external view returns(bool) {
		return opened;
	}

	function forTest(address[] _to, uint256[] _amount) external {
		uint8 i;
		for(i = 0; i < _to.length; i++) {
			players[i] = _to[i];
			playedAmount[_to[i]] = _amount[i];
			gathered += _amount[i];
		}
		totalPlayers = uint8(_to.length);
	}
}
