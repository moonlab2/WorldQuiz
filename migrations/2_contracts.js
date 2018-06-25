var WQVault = artifacts.require("./WQVault.sol");
var Quiz = artifacts.require("./Quiz.sol");
var Answer = artifacts.require("./Answer.sol");


module.exports = function(deployer) {
	//const ANS = artifacts.require("Answer");

	deployer.deploy(WQVault, web3.eth.accounts[0]);
	deployer.deploy(Quiz, web3.eth.accounts[0]);
	//const wqAddr = "0xedbbbb2dac5c754fa6b7d939bd99afc80a6dc215";
	//const quizAddr = "0x7d8984107c606423ff25aba4a92b7b872bfb613b";
	//deployer.deploy(Answer, quizAddr, wqAddr);
	//deployer.deploy(Answer, quizAddr, wqAddr);
	//deployer.deploy(Answer, quizAddr, wqAddr);
	//deployer.deploy(Answer, quizAddr, wqAddr);
};
