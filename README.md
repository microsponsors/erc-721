# Microsponsors ERC-721

Adapted from [Open Zeppelin's ERC721.sol templates](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721) at git tag `v.2.4.0-beta.2` (git sha: [d1158ea](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d1158ea68c597075a5aec4a77a9c16f061beffd3))

## Minting & Transfer Restrictions
Note that there *are* transfer restrictions on these tokens, to satisfy the following business requirements:

1. All minters (Creators) and buyers (Sponsors) must be validated in our Proof-of-Content Registry to eliminate fraud/ impersonation/ spamming.
2. At launch, there will be no reselling to third-parties.
3. When we do support token sales to third-parties, it needs to be third-parties approved by the minter (Creator) to ensure that Creators' time slots aren't sold to individuals or organizations they do not wish to represent.

We also plan to Federate the Registry so that other organizations can implement their own rules and logic (think: (think: DAOs, game studios, media orgs, agencies, consulting, freelancing, etc.)). More information about the [Proof-of-Content Registry is here](https://github.com/microsponsors/registry-contract).

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
