# Microsponsors ERC-721

Adapted from [Open Zeppelin's ERC721.sol template](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721) at git sha [d1158ea](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d1158ea68c597075a5aec4a77a9c16f061beffd3)

## Versioning and Compile
Note that the .sol files are marked `pragma solidity ^0.5.11` and we're using that version in in truffle-config.js `compilers.solc.version`.

#### Remix
In Remix, there is a warning about the use of `extcodehash` unless you compile with the following settings:
* Compiler 0.5.11
* Language Solidity
* EVM Version: `petersburg`

