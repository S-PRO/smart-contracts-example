pragma solidity ^0.4.11;

import "./Token.sol";

contract CustomToken is Token {

    event Emission(uint256 _value);

    function CustomToken(string _name, string _symbol, uint8 _decimals, uint256 startSupply)
    Token(_name, _symbol, _decimals, startSupply){}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice receiver balance will be increased by `_value`
     */
    function emission(address receiver, uint256 _value) onlyOwner {
        // Overflow check
        if (_value + totalSupply < totalSupply) {
            throw;
        }
        totalSupply        += _value;
        balances[receiver] += _value;
        Emission(_value);
    }

    /**
     * @dev Burn the token values from sender balance and from total
     * @param _value amount of token values for burn
     * @notice sender balance will be decreased by `_value`
     */
    function burn(uint _value) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            totalSupply          -= _value;
        }
    }
}