# Test Cases

## Admin
#### owner()
#### transferOwnership()
#### symbol()
#### pause()
#### unpause()

## Admin: Registry management
#### registry()
#### updateRegistryAddress()

## User-facing permission checks (public)
#### isWhitelisted()
#### isMinter()

## Mint
#### mint()
```
mint(
  "dns:foo.com", "0x7465737400000000000000000000000000000000000000000000000000000000",
  1579332938665,
  1579632938665, 1572932938665
);
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

