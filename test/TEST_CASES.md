# Test Cases

## Admin
#### symbol()
#### paused()
#### pause()
#### unpause()

## Admin: Ownership
#### owner1()
#### transferOwnership1()
#### owner2()
#### transferOwnership2()

## Admin: Registry management
#### registry()
#### updateRegistryAddress()

## Admin: Mint Fee
#### mintFee() - public
#### updateMintFee()
#### withdrawBalance()

## Public-facing permission checks
#### isWhitelisted()
#### isMinter()

## Mint
#### mint()
```
mint("foo", "podcast", 1579332938665, 1579632938665, 1572932938665, 1000);
```
#### mintWithTokenURI()
#### safeMint()
#### safeMintWithTokenURI()

## Gets
#### totalSupply()
#### balanceOf()
#### ownerOf()

## Gets - individual tokens
#### tokensOfOwner()
#### tokenURI()
#### tokenTimeSlot()
#### tokenMinterContentIds()
#### tokenMinterPropertyNames()

## Transfers
#### approve()
#### getApproved()
#### setApprovalForAll()
#### isApprovedForAll()
#### transferFrom()
#### safeTransferFrom()

## Burns
#### burn()
#### safeBurn()

---

# Test Scenarios

## Local Setup

Start ganache in one terminal locally, then deploy and start truffle console in another.

Assumes the companion Registry smart contract is already deployed. Update its deployed address in this repo: `/migrations/2_deploy_contracts.js`.

```
$ ganache-cli -p 8545
$ npm run deploy
$ truffle console --network development
> Micropsonsors.deployed().then(inst => { m = inst })
> admin = "<paste 1st address from ganache>"
> account1 = "<paste from ganache>"
> account2 = "<paste from ganache>"
> account3 = "<paste from ganache>"
> contractAddr = "<paste from ganache>"
```
The following test scenarios assume you're querying from truffle console.
`m` = instance created when you deployed this contract.
