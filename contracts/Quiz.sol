/* World Quiz on world computer    by moon.lab
 *
 * Information Page: https://github.com/moonlab2/WorldQuiz
 *                   https://medium.com/@moon.lab2
 * All announcements about quiz will be posted on those pages.
 */
pragma solidity ^0.4.23;

import "./Answer.sol";

contract Quiz {
	address public quizMaker;

	uint8 public numberOfChoices;
	mapping (uint8 => Answer) internal answers;

	uint constant MAXCHOICES = 5;
	uint constant FEE = 993;

	uint256 public sponsored;

	bool public ethLock;

	constructor (address _quizMaker) public {
		quizMaker = _quizMaker;
		ethLock = true;
	}

	modifier onlyQuizMaker() {
		require(msg.sender == quizMaker);
		_;
	}

	function () external payable {
	}

	function changeQuizMaker(address _newQuizMaker) onlyQuizMaker external {
		quizMaker = _newQuizMaker;
	}

	function changeAnswers(address[] _answers) onlyQuizMaker external {
		require(_answers.length == MAXCHOICES);
		for(uint8 i = 0; i < MAXCHOICES; i++)
			answers[i] = Answer(_answers[i]);
	}

	function openQuiz(uint256 _start, uint256 _end, uint8 _cap, uint8 _choices) onlyQuizMaker external {
		require(_choices <= MAXCHOICES);
		uint8 i;
		for(i = 0; i < _choices; i++)
			require(answers[i].isOpen() == false);

		for(i = 0; i < _choices; i++)
			answers[i].openAnswer(_start, _end, _cap);

		numberOfChoices = _choices;
		ethLock = true;
	}

	function closeQuiz(uint8 rightAnswer) onlyQuizMaker external {
		require(rightAnswer < numberOfChoices);
		uint8 i;
		for(i = 0; i < numberOfChoices; i++) {
			answers[i].closeAnswer();
		}

		uint256 W;
		uint256 L;
		uint256 A;

		W = answers[rightAnswer].getGathered();
		for(i = 0; i < numberOfChoices; i++) {
			if(i != rightAnswer)
				L += answers[i].getGathered();
		}

		uint8 total = answers[rightAnswer].getTotalPlayers();
		for(i = 0; i < total; i++) {
			A = answers[rightAnswer].getAmount(i);
			answers[rightAnswer].getAddress(i).transfer(prize(A, W, L));
		}

		ethLock = false;
	}

	function prize(uint256 _A, uint256 _W, uint256 _L) internal pure returns(uint256) {
		return ((_W + _L) * _A * FEE / 1000) / _W;
	}

	function cancelQuiz() onlyQuizMaker public {
		uint8 total;
		for(uint8 i = 0; i < numberOfChoices; i++) {
			total = answers[i].getTotalPlayers();
			for(uint8 j = 0; j < total; j++) {
				answers[i].getAddress(j).transfer(answers[i].getAmount(j));
			}
		}
		ethLock = false;

	}

	function forwardETH(address _to, uint256 _amount) onlyQuizMaker public {
		require(ethLock == false);
		_to.transfer(_amount);
	}

}
