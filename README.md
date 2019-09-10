# Microsponsors ERC-721

Adapted from [Open Zeppelin's ERC721.sol templates](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721) at git tag `v.2.4.0-beta.2` (git sha: [d1158ea](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d1158ea68c597075a5aec4a77a9c16f061beffd3))

#### Install
* Install dependencies: `$ npm install`

#### Lint
Install [solhint](https://www.npmjs.com/package/solhint) globally and run the linter:
```
$ npm install -g solhint
$ npm run lint
```
#### Compiler Versioning
* Compiler: 0.5.11

Note that the .sol files are marked `pragma solidity ^0.5.11` and we're using that version in in truffle-config.js `compilers.solc.version`.

#### Local Deploy
* Start Ganache in another terminal: `$ ganache-cli -p 8545`
* Compile: `$ npm run compile`.
* Deploy to local ganache instance: `$ truffle migrate --network development `
* Or... Compile & Deploy in one step: `$ npm run deploy`

#### Flatten for Remix Deploy
* `$ npm run flatten`

#### Remix & Versioning
In Remix, there is a warning about the use of `extcodehash` unless you compile with the following settings:

* Compiler 0.5.11
* Language Solidity
* EVM Version: `petersburg`
