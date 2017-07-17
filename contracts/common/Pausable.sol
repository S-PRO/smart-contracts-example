pragma solidity ^0.4.11;

import "./Owned.sol";

contract Pausable is Owned {

    bool paused = false;

    function setPausable(bool _paused) onlyOwner {
        paused = _paused;
    }

    modifier checkPause { if (paused) throw; _; }
}