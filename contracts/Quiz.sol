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

	uint constant RETURN = 993;

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
		for(uint8 i = 0; i < _answers.length; i++)
			answers[i] = Answer(_answers[i]);
	}

	function openQuiz(uint256 _start, uint256 _end, uint8 _cap, uint8 _choices) onlyQuizMaker external {
		uint8 i;
		for(i = 0; i < _choices; i++)
			require(answers[i].isOpen() == false);

		for(i = 0; i < _choices; i++)
			answers[i].openAnswer(_start, _end, _cap);

		numberOfChoices = _choices;
		ethLock = true;
	}


	function closeQuiz(uint8 _rightAnswer) onlyQuizMaker external {
		require(_rightAnswer < numberOfChoices);

		for(i = 0; i < numberOfChoices; i++)
			require(answers[i].isOpen());

		uint8 i;
		for(i = 0; i < numberOfChoices; i++) {
			answers[i].closeAnswer(false);
		}

		uint256 W;
		uint256 L;
		uint256 A;

		W = answers[_rightAnswer].getGathered();
		for(i = 0; i < numberOfChoices; i++) {
			if(i != _rightAnswer)
				L += answers[i].getGathered();
		}

		uint8 total = answers[_rightAnswer].getTotalPlayers();
		for(i = 0; i < total; i++) {
			A = answers[_rightAnswer].getAmount(i);
			answers[_rightAnswer].getAddress(i).transfer(prize(A, W, L));
		}

		ethLock = false;
	}

	function prize(uint256 _A, uint256 _W, uint256 _L) internal pure returns(uint256) {
		return ((_W + _L) * _A * RETURN / 1000) / _W;
	}

	function cancelQuiz() onlyQuizMaker public {
		for(i = 0; i < numberOfChoices; i++)
			require(answers[i].isOpen());

		uint8 total;
		uint8 i;
		uint8 j;

		for(i = 0; i < numberOfChoices; i++) {
			answers[i].closeAnswer(false);
		}

		for(i = 0; i < numberOfChoices; i++) {
			total = answers[i].getTotalPlayers();
			for(j = 0; j < total; j++) {
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
