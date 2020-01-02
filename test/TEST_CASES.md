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

## Admin: Reselling
#### isGlobalResaleEnabled() - public
#### enableGlobalResale()
#### disableGlobalResale()

## Admin: Mint Fee
#### mintFee() - public
#### updateMintFee()
#### withdrawBalance()

## Mint
#### mint()
```javascript
mint("foo", "podcast", 1579332938665, 1579632938666, 1572932938664, 1000);
// --> works, if you send mintFee as msg.value
// --> should fail if Content ID is not registered to acct in Registry
//       or account is not whitelisted
// --> should fail without mintFee sent as msg.value
mint("foo", "podcast", 1579332938665, 1579632938666, 1579332938666, 1000);
// --> should fail bc auctionEndTime is after startTime
```
#### mintWithTokenURI()
#### safeMint()
#### safeMintWithTokenURI()

## Gets
#### totalSupply()
#### balanceOf()
#### ownerOf()
#### tokensOfOwner()
#### tokenURI()
#### tokensMintedBy()
#### tokenMinterContentIds()
#### tokenMinterPropertyNames()
#### tokenTimeSlot()

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
