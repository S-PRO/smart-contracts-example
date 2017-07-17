pragma solidity ^0.4.11;

import "./Owned.sol";
import "./Destroyable.sol";

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned, Destroyable {

    function Object() {
        owner  = msg.sender;
        hammer = msg.sender;
    }
}