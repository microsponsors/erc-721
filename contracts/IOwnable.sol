pragma solidity ^0.5.0;

/*
 * Based on 0x's Ownable, but modified here because
 * Open Zeppelin is using solidity pragma 0.5.0 (vs 0x's 0.5.5)
 * import "@0x/contracts-utils/contracts/src/IOwnable.sol";
 */

contract IOwnable {

    function transferOwnership(address newOwner)
        public;
}
