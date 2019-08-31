pragma solidity ^0.5.11;


import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Counters.sol";
import "./ERC165.sol";


// Copy of Deployed Registry contract ABI
// We just use the signatures of the parts we need to interact with:
contract DeployedRegistry {
    mapping (address => bool) public isWhitelisted;
}


/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;


    /***  Contract data  ***/


    // This contract's owner (administator)
    address public owner;

    // Microsponsors Registry (whitelist)
    DeployedRegistry public registry;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to token owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from token owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from token owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Pause. When true, token minting and transfers stop.
    bool public paused = false;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;


    constructor () public {

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);

        // set the contract owner
        owner = _msgSender();
    }


    /*
     * @dev Provides information about the current execution context, including the
     * sender of the transaction and its data. While these are generally available
     * via msg.sender and msg.data, they not should not be accessed in such a direct
     * manner, since when dealing with GSN meta-transactions the account sending and
     * paying for execution may not be the actual sender (as far as an application
     * is concerned).
     */

    function _msgSender() internal view returns (address) {

        return msg.sender;

    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode -
              // see https://github.com/ethereum/solidity/issues/2691
        return msg.data;

    }


    /***  Owner (Administrator) functions  ***/


    /*
     * @dev Sets the contract's owner (administrator)
     * Based on 0x's Ownable, but modified here
     * import "@0x/contracts-utils/contracts/src/Ownable.sol";
     */
    modifier onlyOwner() {
        require(
            _msgSender() == owner,
            "ERC721: caller is not owner"
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

    /**
     * @dev Update address for Microsponsors Registry contract
     * @param newAddress where the Registry contract lives
     */
    function updateRegistryAddress(address newAddress)
        public
        onlyOwner
    {
        registry = DeployedRegistry(newAddress);
    }


    /***  User account permissions  ***/


    /**
     * @dev Checks Registry contract for whitelisted status
     * @param target The address to check
     */
    function isWhitelisted(address target) public view returns (bool) {
        return registry.isWhitelisted(target);
    }

    /**
     * @dev Checks if caller isWhitelisted(),
     * throws with error message and refunds gas if not
     */
    modifier onlyWhitelisted() {

        require(
            isWhitelisted(_msgSender()),
            "ERC721: caller is not whitelisted"
        );
        _;

    }

    /**
     * @dev Checks if minter isWhitelisted()
     */
    function isMinter(address account) public view returns (bool) {
        return isWhitelisted(account);
    }

    /**
     * @dev Checks if caller isMinter(),
     * throws with error message and refunds gas if not
     */
    modifier onlyMinter() {

        require(
            isMinter(_msgSender()),
            "ERC721: caller is not whitelisted for the Minter role"
        );
        _;

    }


    /***  Minting tokens  ***/


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
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");

    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);

        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );

    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);

    }


    /***  Token URIs  ***/


    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(
            _exists(tokenId),
            "ERC721: URI set of nonexistent token"
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
            "ERC721: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId];

    }


    /***  Query balanceOf() a token holder's account  ***/


    /**
     * @dev Gets the balance of the specified address.
     * @param tokenOwner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address tokenOwner) public view returns (uint256) {

        require(
            tokenOwner != address(0),
            "ERC721: balance query for the zero address"
        );

        return _ownedTokensCount[tokenOwner].current();

    }


    /***  Transfers  ***/


    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {

        address tokenOwner = _tokenOwner[tokenId];
        require(
            tokenOwner != address(0),
            "ERC721: token owner query for nonexistent token"
        );

        return tokenOwner;

    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId)
        public
        onlyWhitelisted
        whenNotPaused
    {

        address tokenOwner = ownerOf(tokenId);

        require(
            to != tokenOwner,
            "ERC721: approval is redundant"
        );

        require(
            _msgSender() == tokenOwner || isApprovedForAll(tokenOwner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);

    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {

        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];

    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved)
        public
        onlyWhitelisted
        whenNotPaused
    {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);

    }

    /**
     * @dev Tells whether an operator is approved by a given token owner.
     * @param tokenOwner token owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the token owner
     */
    function isApprovedForAll(address tokenOwner, address operator)
        public
        view
        returns (bool)
    {

        return _operatorApprovals[tokenOwner][operator];

    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId)
        public
        whenNotPaused
    {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        require(
            isWhitelisted(from),
            "ERC721: transfer restricted to whitelisted addresses"
        );

        require(
            isWhitelisted(to),
            "ERC721: transfer restricted to whitelisted addresses"
        );

        _transferFrom(from, to, tokenId);

    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");

    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        whenNotPaused
    {

        require(
            isWhitelisted(from),
            "ERC721: transfer restricted to whitelisted addresses"
        );

        require(
            isWhitelisted(to),
            "ERC721: transfer restricted to whitelisted addresses"
        );

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _safeTransferFrom(from, to, tokenId, _data);

    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        internal
    {

        _transferFrom(from, to, tokenId);

        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );

    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {

        address tokenOwner = _tokenOwner[tokenId];

        return tokenOwner != address(0);

    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {

        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );

        address tokenOwner = ownerOf(tokenId);


        return (spender == tokenOwner || getApproved(tokenId) == spender || isApprovedForAll(tokenOwner, spender));

    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );

        require(
            to != address(0),
            "ERC721: transfer to the zero address"
        );

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);

    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal
        returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);

    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }

    }


    /***  Burn Tokens  ***/


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
            "ERC721: caller is not token owner nor approved"
        );

        _burn(tokenId);

    }


    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {_burn} instead.
     * @param tokenOwner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address tokenOwner, uint256 tokenId) internal {

        require(
            ownerOf(tokenId) == tokenOwner,
            "ERC721: burn of token that is not own"
        );

        _clearApproval(tokenId);

        _ownedTokensCount[tokenOwner].decrement();
        _tokenOwner[tokenId] = address(0);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        emit Transfer(tokenOwner, address(0), tokenId);

    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);

    }


    /*** Pausable (adapted from OpenZeppelin via Cryptokitties) ***/


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
