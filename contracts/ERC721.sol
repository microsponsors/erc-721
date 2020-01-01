pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

/**
 * @title ERC721 Customized for Microsponsors from:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
 */

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Counters.sol";
import "./ERC165.sol";

/**
 * @title Deployed Registry smart contract ABI
 * @dev We just use the signatures of the parts we need to interact with:
 */
contract DeployedRegistry {
    mapping (address => bool) public isWhitelisted;
    function isContentIdRegisteredToCaller(string calldata contentId) external view returns(bool);
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


    /// @dev This contract's owners (administators).
    address public owner1;
    address public owner2;

    // @title DeployedRegistry the Microsponsors Registry Contract
    DeployedRegistry public registry;

    // @dev Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    /// @title _tokenIds All Token IDs minted, incremented starting at 1
    Counters.Counter _tokenIds;

    /// @dev _tokenOwner mapping from Token ID to Token Owner
    mapping (uint256 => address) private _tokenOwner;

    /// @dev _ownedTokensCount mapping from Token Owner to # of owned tokens
    mapping (address => Counters.Counter) private _ownedTokensCount;

    /// @dev _mintedTokensCount mapping from Token Minter to # of minted tokens
    mapping (address => Counters.Counter) private _mintedTokensCount;

    /// @dev mintFee default amt below in wei; can be changed by contract owner
    uint256 public mintFee = 100000000000000;

    /// @dev TimeSlot metadata struct for each token
    ///      TimeSlots timestamps are stored as uint48:
    ///      https://medium.com/@novablitz/storing-structs-is-costing-you-gas-774da988895e
    struct TimeSlot {
        address minter; // the address of the user who mint()'ed this time slot
        string contentId; // the users' registered contentId containing the Property
        string propertyName; // describes the Property within the contentId that is tokenized into time slots
        uint48 startTime; // min timestamp (when time slot begins)
        uint48 endTime; // max timestamp (when time slot ends)
        uint48 auctionEndTime; // max timestamp (when auction for time slot ends)
        uint16 category; // integer that represents the category (see Microsponsors utils.js)
    }
    /// @dev _tokenToTimeSlot mapping from Token ID to TimeSlot struct
    mapping(uint256 => TimeSlot) private _tokenToTimeSlot;

    /// @dev PropertyNameStruct: name of the time slot
    struct PropertyNameStruct {
        string propertyName;
    }
    /// @dev _tokenMinterToPropertyName mapping from Minter => Content ID => array of Property Names
    ///      Used to display all tokenized Time Slots on a given Property.
    ///      Using struct because there is no mapping to a dynamic array of bytes32 in Solidity at this time.
    mapping(address => mapping(string => PropertyNameStruct[])) private _tokenMinterToPropertyNames;

    /// @dev ContentIdStruct The registered Content ID, verified by Registry contract
    struct ContentIdStruct {
        string contentId;
    }
    /// @dev _tokenMinterToContentIds Mapping from Token Minter to array of Content IDs
    ///      that they have *ever* minted tokens for
    mapping(address => ContentIdStruct[]) private _tokenMinterToContentIds;

    /// @dev _tokenURIs Mapping from Token ID to Token URIs
    mapping(uint256 => string) private _tokenURIs;

    /// @dev _tokenApprovals Mapping from Token ID to Approved Address
    mapping (uint256 => address) private _tokenApprovals;

    /// @dev _operatorApprovals Mapping from Token Owner to Operator Approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /// @dev paused When true, token minting and transfers stop.
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

        // Register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);

        // Set the contract owners to msg.sender by default
        owner1 = _msgSender();
        owner2 = _msgSender();

    }


    /**
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


    /**
     * @dev Sets the contract's owner (administrator)
     * Based on 0x's Ownable, but modified here
     */
    modifier onlyOwner() {
        require(
            (_msgSender() == owner1) || (_msgSender() == owner2),
            "ERC721: ONLY_CONTRACT_OWNER"
        );
        _;
    }


    /**
     * @dev Transfer owner (admin) functions to another address
     * @param newOwner Address of new owner/ admin of contract
     */
    function transferOwnership1(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner1 = newOwner;
        }
    }


    function transferOwnership2(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner2 = newOwner;
        }
    }


    /**
     * @dev Update contract address for Microsponsors Registry contract
     * @param newAddress where the Registry contract lives
     */
    function updateRegistryAddress(address newAddress)
        public
        onlyOwner
    {
        registry = DeployedRegistry(newAddress);
    }


    /**
     * @dev Update the fee (in wei) charged for minting a single token
     */
    function updateMintFee(uint256 val)
        public
        onlyOwner
    {

        mintFee = val;

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
     * @dev Checks if caller isWhitelisted()
     *      throws with error message and refunds gas if not
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
     *      throws with error message and refunds gas if not
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
     * @return tokenId
     */
    function mint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category
    )
        public
        payable
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(msg.value >= mintFee);

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _mint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category);

        return tokenId;

    }

    /**
     * @dev Function to mint tokens.
     * @param tokenURI The token URI of the minted token.
     * @return tokenId
     */
    function mintWithTokenURI(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        string memory tokenURI
    )
        public
        payable
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(msg.value >= mintFee);

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _mint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;

    }

    /**
     * @dev Function to safely mint tokens.
     * @return tokenId
     */
    function safeMint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category
    )
        public
        payable
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(msg.value >= mintFee);

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category);

        return tokenId;

    }

    /**
     * @dev Function to safely mint tokens.
     * @param data bytes data to send along with a safe transfer check.
     * @return tokenId
     */
    function safeMint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bytes memory data
    )
        public
        payable
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(msg.value >= mintFee);

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(_msgSender(), data);
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category);

        return tokenId;

    }

    /**
     * @param tokenURI The token URI of the minted token.
     * @return tokenId
     */
    function safeMintWithTokenURI(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        string memory tokenURI
    )
        public
        payable
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(msg.value >= mintFee);

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;

    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @return tokenId
     */
    function _safeMint(address to) internal returns (uint256) {

        uint256 tokenId = _safeMint(to, "");
        return tokenId;

    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param data bytes data to send along with a safe transfer check
     * @return tokenId
     */
    function _safeMint(address to, bytes memory data) internal returns (uint256) {

        uint256 tokenId = _mint(to);

        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );

        return tokenId;

    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     */
    function _mint(address to) internal returns (uint256) {

        require(to != address(0), "ERC721: mint to the zero address");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        _mintedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);

        return tokenId;

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
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     * @return URI for a given token ID.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(
            _exists(tokenId),
            "ERC721: URI query for nonexistent token"
        );

        return _tokenURIs[tokenId];

    }


    /***  Token TimeSlot data and metadata  ***/


    function _isValidTimeSlot(
        string memory contentId,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime
    ) internal view returns (bool) {

        require(
            registry.isContentIdRegisteredToCaller(contentId),
            "ERC721: content id is not registered to caller"
        );

        require(
            startTime > auctionEndTime,
            "ERC721: start time must be after its auction end time"
        );

        require(
            endTime > startTime,
            "ERC721: start time must be before end time"
        );

        return true;

    }


    function _isContentIdMappedToMinter(
        string memory contentId
    )  internal view returns (bool) {

        ContentIdStruct[] memory a = _tokenMinterToContentIds[msg.sender];
        bool foundMatch = false;
        for (uint i = 0; i < a.length; i++) {
            if (stringsMatch(contentId, a[i].contentId)) {
                foundMatch = true;
            }
        }

        return foundMatch;
    }


    function _isPropertyNameMappedToMinter(
        string memory contentId,
        string memory propertyName
    )  internal view returns (bool) {

        PropertyNameStruct[] memory a = _tokenMinterToPropertyNames[msg.sender][contentId];
        bool foundMatch = false;
        for (uint i = 0; i < a.length; i++) {
            if (stringsMatch(propertyName, a[i].propertyName)) {
                foundMatch = true;
            }
        }

        return foundMatch;
    }


    function _setTokenTimeSlot(
        uint256 tokenId,
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category
    ) internal {

        require(
            _exists(tokenId),
            "ERC721: non-existent token"
        );

        TimeSlot memory _timeSlot = TimeSlot({
            minter: address(_msgSender()),
            contentId: string(contentId),
            propertyName: string(propertyName),
            startTime: uint48(startTime),
            endTime: uint48(endTime),
            auctionEndTime: uint48(auctionEndTime),
            category: uint16(category)
        });

        _tokenToTimeSlot[tokenId] = _timeSlot;

        if (!_isContentIdMappedToMinter(contentId)) {
            _tokenMinterToContentIds[_msgSender()].push( ContentIdStruct(contentId) );
        }

        if (!_isPropertyNameMappedToMinter(contentId, propertyName)) {
            _tokenMinterToPropertyNames[_msgSender()][contentId].push( PropertyNameStruct(propertyName) );
        }

    }


    function tokenTimeSlot(uint256 tokenId) external view returns (
            address minter,
            address owner,
            string memory contentId,
            string memory propertyName,
            uint48 startTime,
            uint48 endTime,
            uint48 auctionEndTime,
            uint16 category
    ) {

        require(
            _exists(tokenId),
            "ERC721: Non-existent Token ID"
        );

        TimeSlot memory _timeSlot = _tokenToTimeSlot[tokenId];

        return (
            _timeSlot.minter,
            ownerOf(tokenId),
            _timeSlot.contentId,
            _timeSlot.propertyName,
            _timeSlot.startTime,
            _timeSlot.endTime,
            _timeSlot.auctionEndTime,
            _timeSlot.category
        );

    }


    /***  Token minter queries  ***/


    /// @dev Look up all Content IDs a Minter has tokenized TimeSlots for.
    ///      We're not getting this from the Registry because we want to keep
    ///      a separate record here of all Content ID's the acct has *ever*
    ///      minted tokens for. The registry is for keeping track of their
    ///      current (not necessarily past) Content ID registrations.
    function tokenMinterContentIds(address minter) external view returns (string[] memory) {

        ContentIdStruct[] memory m = _tokenMinterToContentIds[minter];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] = m[i].contentId;
        }

        return r;

    }

    /// @dev Look up all Property Names a Minter has created Time Slots for
    ///      with a particular Content ID
    function tokenMinterPropertyNames(
        address minter,
        string calldata contentId
    ) external view returns (string[] memory) {

        PropertyNameStruct[] memory m = _tokenMinterToPropertyNames[minter][contentId];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].propertyName;
        }

        return r;

    }


    /**
     * Return all the Token IDs minted by a given account.
     * @dev This method MUST NEVER be called by smart contract code. First, it's fairly
     *  expensive (it walks the entire _tokenIds array looking for tokens belonging to minter),
     *  but it also returns a dynamic array, which is only supported for web3 calls, and
     *  not contract-to-contract calls (at this time).
     */
    function tokensMintedBy(address minter) external view returns (uint256[] memory) {

        require(
            minter != address(0),
            "ERC721: cannot query the zero address"
        );

        uint256 tokenCount = _mintedTokensCount[minter].current();
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;

            // All Tokens have IDs starting at 1 and increase
            // sequentially up to the total supply count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (_tokenToTimeSlot[tokenId].minter == minter) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }

    }


    /***  Token balance and ownership queries  ***/


    /**
     * @dev Gets the total number of tokens ever minted.
     */
    function totalSupply() public view returns (uint256) {

        return _tokenIds.current();

    }

    /**
     * @dev Gets the balance of the specified address.
     * @param tokenOwner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address tokenOwner) public view returns (uint256) {

        require(
            tokenOwner != address(0),
            "ERC721: cannot query the zero address"
        );

        return _ownedTokensCount[tokenOwner].current();

    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {

        address tokenOwner = _tokenOwner[tokenId];

        return tokenOwner;

    }

    /**
     * @param tokenOwner The owner whose tokens we are interested in.
     * @dev This method MUST NEVER be called by smart contract code. First, it's fairly
     *  expensive (it walks the entire _tokenIds array looking for tokens belonging to owner),
     *  but it also returns a dynamic array, which is only supported for web3 calls, and
     *  not contract-to-contract calls (at this time).
    */
    function tokensOfOwner(address tokenOwner) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(tokenOwner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;

            // All Tokens have IDs starting at 1 and increase
            // sequentially up to the total count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (_tokenOwner[tokenId] == tokenOwner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }


    /***  Transfers  ***/


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
     * @param data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
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

        _safeTransferFrom(from, to, tokenId, data);

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
     * @param data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        internal
    {

        _transferFrom(from, to, tokenId);

        require(
            _checkOnERC721Received(from, to, tokenId, data),
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
     *      As opposed to {transferFrom}, this imposes no restrictions on msg.sender
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
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data)
        internal
        returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data);
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
     * @dev Customized for Microsponsors
     *      https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Burnable.sol     * @dev Burns a specific ERC721 token.
     * @param tokenId uint256 id of the ERC721 token to be burned
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

        // Clear token URIs (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        // Clear time slot data
        delete _tokenToTimeSlot[tokenId];

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


    /*** Withdraw ***/


    function withdrawBalance() external onlyOwner {

        // Ref: https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/
        uint balance = address(this).balance;
        (bool success, ) = msg.sender.call.value(balance)("");
        require(success, "Withdraw failed");

    }


    /***  Helper fn  ***/

    function stringsMatch (
        string memory a,
        string memory b
    )
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }

}
