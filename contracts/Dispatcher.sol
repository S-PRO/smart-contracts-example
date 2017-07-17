pragma solidity ^0.4.11;

import "./common/Owned.sol";

contract Dispatcher is Owned {

    // DApp must always get this addresses to use last version of contract
    address public currentCustomTokenAddress;
    address public currentMarketAddress;

    function Dispatcher() {
        owner = msg.sender;
    }

    function setCurrentCustomTokenAddress(address _address) onlyOwner {
        currentCustomTokenAddress = _address;
    }

    function setCurrentMarketAddress(address _address) onlyOwner {
        currentMarketAddress = _address;
    }
}