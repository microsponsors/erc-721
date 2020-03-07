# Microsponsors MSPT Time Slot Tokens
### ERC-721 compatible Non-Fungible Tokens (NFT)

Adapted from [Open Zeppelin's ERC721.sol templates](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721) at git tag `v.2.4.0-beta.2` (git sha: [d1158ea](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d1158ea68c597075a5aec4a77a9c16f061beffd3))

Each MSPT can be queried by tokenId:
```
tokenTimeSlot(23);
```
Returns:
```javascript
{
minter, // Ethereum address of the token's Minter/Creator
owner, // Ethereum address of the token's current owner
contentId, // the creator's web domain, url, social media account or email
propertyName, // short re-usable description of time slot
startTime, // UTC timestamp; when the time slot begins
endTime, // UTC timestamp; when the time slot ends
auctionEndTime, // UTC timestamp; when the auction ends
category, // for sorting tokens by creator type
isSecondaryTradingEnabled, // can be true or false, up to the Minter/Creator
federationId, // which registry to check for transfer restrictions
}
```

## Smart Contract Addresses/ Deployments
See [DEPLOYS.md](DEPLOYS.md)

## See All Contract Methods
See [test/TEST_CASES.md](test/TEST_CASES.md)

## Minting & Transfer Restrictions
Note that there *are* transfer restrictions on these tokens, to satisfy the following business requirements:

1. All Minters (Creators) must be validated in our Proof-of-Content Registry to help eliminate fraud/ impersonation/ spamming.
2. Microsponsors ERC-721s (NFTs) give Minters the option to disable token resale to third-parties, to help ensure that their time slots aren't sold to anyone they do not wish to transact with. This is useful for certain use-cases, i.e. Creators who want to carefully choose which organizations they wish to work with.

## Path to Federation

We plan to Federate so that other organizations can implement their own rules and logic around Registration, token minting, selling and re-selling (think: DAOs, game studios, media orgs, agencies, consultants, freelancers, etc).

More information about how this will work in our [Proof-of-Content Registry](https://github.com/microsponsors/registry-contract).

---

#### Install
* Install dependencies: `$ npm install`

#### Lint
Install [solhint](https://www.npmjs.com/package/solhint) globally and run the linter:
```
$ npm install -g solhint
$ npm run lint
```

#### Local Compile & Deploy
* Start Ganache in another terminal: `$ ganache-cli -p 8545`
* Compile: `$ npm run compile`. Rebuilds `/build` dir.
* Deploy to local ganache instance: `$ truffle migrate --network development `
* Or... Compile & Deploy in one step: `$ npm run deploy`

##### Solidity Compiler Version
* Compiler: 0.5.11

Note: .sol files are marked `pragma solidity ^0.5.11` and we're using same in truffle-config.js `compilers.solc.version`.

#### Flatten for Remix Deploy
* `$ npm run flatten`

#### Remix & Versioning
In Remix, there is a warning about the use of `extcodehash` unless you compile with the following settings:

* Compiler 0.5.11
* Language Solidity
* EVM Version: `petersburg`
* Check "Enable optimization"

#### Git tag + DEPLOYS.md
Each public network deployment is git tagged (starting with `v0.1`) and recorded in [DEPLOYS.md](DEPLOYS.md)

---

#### Note on ABIEncoderV2
This contract is using `pragma experimental ABIEncoderV2`. Because both [0x](https://0x.org) and [dydx](https://dydx.exchange/) have been using it for many months, and critical bugs were fixed as far back as Solidity 0.5.4, we think its probably ok to use in production. Remarks on this [from the dydx team via Open Zeppelin blog](https://blog.openzeppelin.com/solo-margin-protocol-audit-30ac2aaf6b10/).
