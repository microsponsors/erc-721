pragma solidity ^0.5.11;


/*
 * Based on 0x's Ownable, but modified here because
 * Open Zeppelin is using solidity pragma 0.5.0 (vs 0x's 0.5.5)
 * import "@0x/contracts-utils/contracts/src/Ownable.sol";
 */
 import "./IOwnable.sol";


contract Ownable is
    IOwnable
{
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
