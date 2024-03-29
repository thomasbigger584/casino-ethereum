
// require the Casino.sol contract
var Casino = artifacts.require("./Casino.sol");


// minimum bet is 0.1 ether converted to wei
// gas limit that we are willing to use to deploy the contract
module.exports = function(deployer) {
  deployer.deploy(web3.toWei(0.1, 'ether'), 100, {gas: 3000000});
};
