pragma solidity ^0.4.11;

import "../common/Object.sol";
import "../Dispatcher.sol";
import "../token/CustomToken.sol";

contract SellOffer is Object {

    Dispatcher dispatcher;
    CustomToken token;

    struct sellOffer {
        uint time;
        address from;
        uint256 amount;
        uint256 price;
    }
    sellOffer[] sellOffers;
    mapping(address => uint256[]) mySellOffers;
    uint8 public fee = 1; // 1%

    /// @notice Before deploy this contract you must deploy dispatcher contract and set CustomToken address to it first
    function SellOffer(address dispatcherAddress) {
        hammer = msg.sender;
        dispatcher = Dispatcher(dispatcherAddress);
        token = CustomToken(dispatcher.currentCustomTokenAddress());
    }

    /// @notice The owner set amount of fee
    function setFee(uint8 _fee) onlyOwner {
        fee = _fee;
    }

    /// @notice The owner can withdraw the funds earned by the contract
    function withdraw(uint256 _value) onlyOwner {
        if (this.balance >= _value) {
            if (!owner.send(_value)) {
                throw;
            }
        }
    }

    /// @notice The owner can destroy contract
    function destroy() onlyHammer {
        for (uint i = 0; i < sellOffers.length; i++) {
            cancel(i);
        }
        selfdestruct(msg.sender);
    }

    /// @notice Anybody can create his offer for sale. But before you must approve this contract to spend your tokens
    function createSellOffer(uint256 _amount, uint256 _price) {
        sellOffer memory offer;
        offer.time = now;
        offer.from = msg.sender;
        offer.amount = _amount;
        offer.price = _price;
        if (token.transferFrom(msg.sender, address(this), _amount)) {
            mySellOffers[msg.sender].push(sellOffers.push(offer));
        }
    }

    function getAllSellOffersCount() constant returns (uint) {
        return sellOffers.length;
    }

    function getMySellOffersCount() constant returns (uint) {
        return mySellOffers[msg.sender].length;
    }

    /// @notice Get offer of sale by index
    function getSellOffer(uint index) constant returns (uint time, address from, uint256 amount, uint256 price) {
        sellOffer memory offer = sellOffers[index];
        return (offer.time, offer.from, offer.amount, offer.price);
    }

    /// @notice Anybody can buy some tokens by offer index if he send some founds to this contract
    function buy(uint index) payable {
        sellOffer memory offer = sellOffers[index];
        uint256 sum = offer.amount * offer.price;
        uint256 feeAmount = sum * fee / 100;
        if (msg.value < sum + feeAmount) {
            throw;
        }
        uint256 back = msg.value - (sum + feeAmount);
        if (token.transfer(msg.sender, offer.amount)) {
            if (!offer.from.send(sum)) {
                throw;
            }
            if (!msg.sender.send(back)) {
                throw;
            }
            deleteSellOffer(index);
            deleteIndex(offer, index);
        } else {
            throw;
        }
    }

    /// @notice Anybody can cancel only his offers of sale. Owner can cancel all offers
    function cancel(uint index) {
        sellOffer memory offer = sellOffers[index];
        if (offer.from == msg.sender || msg.sender == owner) {
            if (token.transfer(offer.from, offer.amount)) {
                deleteSellOffer(index);
                deleteIndex(offer, index);
            }
        }
    }

    function deleteSellOffer(uint index) private {
        uint length = sellOffers.length;
        if (length > 1) {
            sellOffers[index] = sellOffers[length - 1];
        }
        sellOffers.length = length - 1;
    }

    function deleteIndex(sellOffer offer, uint256 index) private {
        uint256[] indexes = mySellOffers[offer.from];
        uint256 length = indexes.length;
        for (uint i = 0; i < length; i++) {
            if (indexes[i] == index) {
                if (length > 1) {
                    indexes[i] = indexes[length - 1];
                }
                indexes.length = length - 1;
                break;
            }
        }
    }

    /// @notice Fallback function of contract to receive founds
    function() payable {}
}