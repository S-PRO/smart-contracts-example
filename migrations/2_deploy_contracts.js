var Dispatcher = artifacts.require("./Dispatcher.sol");
var CustomToken = artifacts.require("./token/CustomToken.sol");
var SellOffer = artifacts.require("./market/SellOffer.sol");

module.exports = function(deployer) {
  deployer.deploy(Dispatcher);
  deployer.deploy(CustomToken).then(function() {
    Dispatcher.deployed().then(function(instance) {
      return instance.setCurrentCustomTokenAddress(CustomToken.address);
    }).then(function(result) {
      deployer.deploy(SellOffer, Dispatcher.address);
    });
    return;
  });
};