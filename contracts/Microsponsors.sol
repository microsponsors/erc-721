pragma solidity ^0.5.11;


import "./ERC721.sol";
import "./Ownable.sol";


// Copy of Deployed Registry contract ABI
// We just use the signatures of the parts we need to interact with:
contract DeployedRegistry {
    mapping (address => bool) public isWhitelisted;
}


/**
 * Customized for Microsponsors
 * from Open Zeppelin's ERC721Metadata contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Metadata.sol
 */
contract Microsponsors is ERC721, Ownable {

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Microsponsors Registry (whitelist)
    DeployedRegistry public registry;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Pause. When true, token minting and transfers stop.
    bool public paused = false;


    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol, address registryAddress) public {

        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

        registry = DeployedRegistry(registryAddress);

    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Update address for Microsponsors Registry contract
     * @param newAddress where the Registry contract lives
     */
    function updateRegistryAddress(address newAddress) public onlyOwner {
        require(msg.sender == owner, 'NOT_AUTHORIZED');
        registry = DeployedRegistry(newAddress);
    }

    /**
     * @dev Checks Registry contract for whitelisted status
     * @param target The address to check
     */
    function isWhitelisted(address target) public view returns (bool) {
        return registry.isWhitelisted(target);
    }

    function isMinter(address account) public view returns (bool) {
        return isWhitelisted(account);
    }

    modifier onlyMinter() {

        require(
            isMinter(_msgSender()),
            "MinterRole: caller is not whitelisted for the Minter role"
        );
        _;

    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 tokenId)
        public
        onlyMinter
        whenNotPaused
        returns (bool)
    {

        _mint(to, tokenId);
        return true;

    }

    // solhint-disable
    /**
     * Customized for Microsponsors from:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
     *
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    // solhint-enable
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI)
        public
        onlyMinter
        whenNotPaused
        returns (bool)
    {

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;

    }

    /**
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function safeMint(address to, uint256 tokenId)
        public
        onlyMinter
        whenNotPaused
        returns (bool)
    {

        _safeMint(to, tokenId);
        return true;

    }

    /**
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @param _data bytes data to send along with a safe transfer check.
     * @return A boolean that indicates if the operation was successful.
     */
    function safeMint(address to, uint256 tokenId, bytes memory _data)
        public
        onlyMinter
        whenNotPaused
        returns (bool)
    {

        _safeMint(to, tokenId, _data);
        return true;

    }

    // solhint-disable
    /**
     * Customized for Microsponsors from
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
     *
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    // solhint-enable
    function safeMintWithTokenURI(address to, uint256 tokenId, string memory tokenURI)
        public
        onlyMinter
        whenNotPaused
        returns (bool)
    {

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;

    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = uri;

    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId];

    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param tokenOwner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address tokenOwner, uint256 tokenId) internal {

        super._burn(tokenOwner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

    }

    // solhint-disable
    /**
     * Customized for Microsponsors
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Burnable.sol     * @dev Burns a specific ERC721 token.
     * @param tokenId uint256 id of the ERC721 token to be burned.
     */
     // solhint-enable
    function burn(uint256 tokenId) public whenNotPaused {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        _burn(tokenId);

    }


    /*** Pausable adapted from OpenZeppelin via Cryptokitties ***/


    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by contract owner to pause actions on this contract
    function pause() external onlyOwner whenNotPaused {
        paused = true;
    }

    /// @dev Called by contract owner to unpause the smart contract.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyOwner whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }


}
