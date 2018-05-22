pragma solidity ^0.4.23;

contract Answer {
	address public quiz;

	uint256 public gathered;
	uint256 public cap;

	uint256 public startTime;
	uint256 public endTime;

	bool public opened;

	mapping (address => uint256) public playedAmount;
	mapping (uint256 => address) public players;

	uint256 public totalPlayers;


	constructor (address _quiz) public {
		quiz = _quiz;

		opened = false;
	}

	modifier fromQuizContract() {
		require(msg.sender == quiz);
		_;
	}

	function changeQuiz(address _quiz) fromQuizContract external {
		quiz = _quiz;
	}

	function openAnswer(uint256 _start, uint256 _end, uint _cap) fromQuizContract external {
		require(!opened);

		startTime = _start;
		endTime = _end;
		cap = _cap;

		opened = true;
		gathered = 0;

		for(uint256 i = 0; i < totalPlayers; i++) {
			playedAmount[players[i]] = 0;
		}

		totalPlayers = 0;
	}

	function closeAnswer() fromQuizContract external returns (bool){
		if(!opened)
			return false;

		quiz.transfer(gathered);

		opened = false;
	}

	function () external payable {
		require(startTime <= now && now <= endTime);
		uint256 checkup;
		checkup = msg.value >= 10 ** 18 ? 10 ** 15 : msg.value / 1000;

		// check if the msg.sender is possible to receive
		msg.sender.transfer(chekcup);

		if(playedAmount[msg.sender] == 0) {
			players[totalPlayers] = msg.sender;
			totalPlayers++;
		}
		playedAmount[msg.sender] += msg.value - chekcup;
		gathered += msg.value - chekcup;
	}
	
	function getAddress(uint256 _no) external view returns(address) {
		return players[_no];
	}

	function getAmount(uint256 _no) external view returns(uint256) {
		return playedAmount[players[_no]];
	}


	function getGathered() external view returns(uint256) {
		return gathered;
	}
	function getTotalPlayers() external view returns(uint256) {
		return totalPlayers;
	}
	function isOpen() external view returns(bool) {
		return opened;
	}
}
