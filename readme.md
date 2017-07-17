## Description
This is an example of a token market.



The token owner produces the initial emission of a certain number of tokens that are credited to his wallet. In the future, new emission of tokens can be produced in someone's favor (`CustomToken.emission (receiver, amount)`). Anyone interested will be notified about it (`event Emission (uint256 amount)`).


The owner of the market organizes the sale of tokens between the participants. He or she sets the fee amount (`SellOffer.setFee (fee)`), which will be
withdrawed from the buyer for the purchase of tokens in favor of the market. Also, he or she can withdraw a portion of the money "earned" by the market on the wallet
(`SellOffer.withdraw (amount)`). In addition, the market owner can close the market returning all the unsold tokens to their holders and
Withdrawal of all "earned" funds to own wallet (`SellOffer.destroy ()`).


Any market participant can view the total number of offers on the market (`SellOffer.getAllSellOffersCount ()`), the number of own offers
(`SellOffer.getMySellOffersCount ()`) and the current fee amount (`SellOffer.fee ()`). Also it's easy to choose any proposal by
its number (`SellOffer.getSellOffer (index)`) and make a deal by the offer number after transferring the sufficient
funds in the same transaction  (`SellOffer.buy (index)`). If necessary, the market will return the change.

The token owner can create a sell offer by specifying the quantity and price in wei (1 ether * 10 ^ -18) (`SellOffer.createSellOffer
(Amount, price) `). To do this, before placing the proposal itself, it's important to create the permit for the market contract to get a certain number of tokens from the wallet (`CustomToken.approve (spender, value)`). The placeholder can cancel the proposal and return tokens without a market commission to the wallet (`SellOffer.cancel (index)`).



## Required components
 
- You must install a network client Ethereum - Geth (https://geth.ethereum.org/downloads).
 
- To place contracts on the network you can choose to install either Mist (https://github.com/ethereum/mist/releases) or Truffle 
 (http://truffleframework.com) or even both.



## Components configuration

### Running the Network Node
Run the Geth in a console and indicate Geth to use private test network Ethereum:

- geth --dev --rpc --rpccorsdomain="*" --rpcaddr "0.0.0.0" --rpcapi "admin,debug,miner,shh,txpool,personal,eth,net,web3" console



### Mist configuration

 Run Mist in a separate console and indicate Mist to use not embedded client of Ethereum network: 

- mist --rpc http://localhost:8545



### Truffle configuration

To configurate Truffle you need to edit truffle.js

 file

```module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
```

### Miner creation 

In order to create an account in the Geth console, you need to run the command 
- personal.newAccount("password").
 


In order to create an account in Mist, you need to click the corresponding button.

The first account created will be automatically assigned as a miner.

When placing the contracts, you have to pay a commission for carrying out the transaction in the blockchain, so you need to run the miner. To do this execute the command in Geth console:
- miner.start()



To stop mining:

- miner.stop()


## Placement of contracts

To conduct all transactions, placing and calling contracts (except for static ones) the miner has to work.


1) The Dispatcher contract is placed

2) A CustomToken contract is placed with the name of the token, its symbol, the number of fractional orders and the value of the initial fee

3) The address of the posted CustomToken contract is assigned to the Dispatcher from the Account name that posted the Dispatcher

4) The SellOffer contract is placed with the address of the previously placed Dispatcher contract

### Placement with Mist

To place contracts in Mist, you need to go to the appropriate section, then:

- select an account on behalf of which the placement will take place,

- if necessary, indicate the number of funds transferred to the contract,
- insert the source code,

- choose the name of the contract,

- specify the parameters of the constructor,

- specify the fee amount,

- click the placement button and specify the password from the posting account

Since Mist does not know how to make import, you better insert either all the code of the imported contract or its abstract analog (if you use the implementation, that was previously placed in the blockchain)


### Placement with Truffle

To place contracts using Truffle, you must create the appropriate migration files:
- 1_initial_migration.js
```
var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
```
- 2_deploy_contracts.js
```
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
```
- etc.



Then in the Geth console you need to unlock the account on whose behalf the counter placement will be executed and enter the password:
- personal.unlockAccount ("account_address")

Then execute the command in the console from the project directory:
- truffle migrate