
// File: contracts/IERC165.sol

pragma solidity ^0.5.11;


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/IERC721.sol

pragma solidity ^0.5.11;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed tokenOwner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed tokenOwner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address tokenOwner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address tokenOwner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address tokenOwner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: contracts/IERC721Receiver.sol

pragma solidity ^0.5.11;


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

// File: contracts/SafeMath.sol

pragma solidity ^0.5.11;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.

     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/Address.sol

pragma solidity ^0.5.11;


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

// File: contracts/Counters.sol

pragma solidity ^0.5.11;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

// File: contracts/ERC165.sol

pragma solidity ^0.5.11;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/ERC721.sol

pragma solidity ^0.5.11;








// Copy of Deployed Registry contract ABI
// We just use the signatures of the parts we need to interact with:
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

    // This contract's owner (administator)
    address public owner;

    // Microsponsors Registry (whitelist)
    DeployedRegistry public registry;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // All token ids minted, incremented starting at 1
    Counters.Counter _tokenIds;

    // Mapping from token ID to token owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from token owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from token owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token's time slot metadata
    struct TimeSlot {
        string contentId; // the property that whose time slots are tokenized
        uint32 startTime; // timestamp for when sponsorship begins
        uint32 endTime; // max timestamp of sponsorship (when it ends)
    }

    // Mapping from token ID to time slot struct
    mapping(uint256 => TimeSlot) private _tokenToTimeSlot;

    // Mapping from token ID to token URIs
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
     * @return tokenId
     */
    function mint(
        address to,
        string memory contentId,
        uint32 startTime,
        uint32 endTime
    )
        public
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(
            _isValidTimeSlot(contentId, startTime, endTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _mint(to);
        _setTokenTimeSlot(tokenId, contentId, startTime, endTime);

        return tokenId;

    }

    // solhint-disable
    /**
     * Customized for Microsponsors from:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
     *
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenURI The token URI of the minted token.
     * @return tokenId
     */
    // solhint-enable
    function mintWithTokenURI(
        address to,
        string memory contentId,
        uint32 startTime,
        uint32 endTime,
        string memory tokenURI
    )
        public
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(
            _isValidTimeSlot(contentId, startTime, endTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _mint(to);
        _setTokenTimeSlot(tokenId, contentId, startTime, endTime);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;

    }

    /**
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted token.
     * @return tokenId
     */
    function safeMint(
        address to,
        string memory contentId,
        uint32 startTime,
        uint32 endTime
    )
        public
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(
            _isValidTimeSlot(contentId, startTime, endTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(to);
        _setTokenTimeSlot(tokenId, contentId, startTime, endTime);

        return tokenId;

    }

    /**
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted token.
     * @param data bytes data to send along with a safe transfer check.
     * @return tokenId
     */
    function safeMint(
        address to,
        string memory contentId,
        uint32 startTime,
        uint32 endTime,
        bytes memory data
    )
        public
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(
            _isValidTimeSlot(contentId, startTime, endTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(to, data);
        _setTokenTimeSlot(tokenId, contentId, startTime, endTime);

        return tokenId;

    }

    // solhint-disable
    /**
     * Customized for Microsponsors from
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
     *
     * @dev Function to safely mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenURI The token URI of the minted token.
     * @return tokenId
     */
    // solhint-enable
    function safeMintWithTokenURI(
        address to,
        string memory contentId,
        uint32 startTime,
        uint32 endTime,
        string memory tokenURI
    )
        public
        onlyMinter
        whenNotPaused
        returns (uint256)
    {

        require(
            _isValidTimeSlot(contentId, startTime, endTime),
            "ERC721: invalid time slot"
        );

        uint256 tokenId = _safeMint(to);
        _setTokenTimeSlot(tokenId, contentId, startTime, endTime);
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
     * @param _data bytes data to send along with a safe transfer check
     * @return tokenId
     */
    function _safeMint(address to, bytes memory _data) internal returns (uint256) {

        uint256 tokenId = _mint(to);

        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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


    /***  Token TimeSlot data  ***/


    function _isValidTimeSlot(
        string memory contentId,
        uint32 startTime,
        uint32 endTime
    ) internal view returns (bool) {

        require(
            registry.isContentIdRegisteredToCaller(contentId),
            "ERC721: content id is not registered to caller"
        );

        require(
            endTime > startTime,
            "ERC721: token start time must be before end time"
        );

        return true;

    }


    function _setTokenTimeSlot(
        uint256 tokenId,
        string memory contentId,
        uint32 startTime,
        uint32 endTime
    ) internal {

        require(
            _exists(tokenId),
            "ERC721: URI set of nonexistent token"
        );

        TimeSlot memory _timeSlot = TimeSlot({
            contentId: string(contentId),
            startTime: uint32(startTime),
            endTime: uint32(endTime)
        });

        _tokenToTimeSlot[tokenId] = _timeSlot;

    }


    function tokenTimeSlot(uint256 tokenId) external view returns (
            string memory contentId,
            uint32 startTime,
            uint32 endTime
    ) {

        require(
            _exists(tokenId),
            "ERC721: Time slot query for nonexistent token id"
        );

        return (
            _tokenToTimeSlot[tokenId].contentId,
            _tokenToTimeSlot[tokenId].startTime,
            _tokenToTimeSlot[tokenId].endTime
        );

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
            "ERC721: balance query for the zero address"
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
        require(
            tokenOwner != address(0),
            "ERC721: token owner query for nonexistent token"
        );

        return tokenOwner;

    }

    /**
     * @param tokenOwner The owner whose tokens we are interested in.
     * @dev This method MUST NEVER be called by smart contract code. First, it's fairly
     *  expensive (it walks the entire _tokenIds array looking for tokens belonging to owner),
     *  but it also returns a dynamic array, which is only supported for web3 calls, and
     *  not contract-to-contract calls.
     * @return uint256 Returns a list of all token id's assigned to an address.
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

            // We count on the fact that all tokens have IDs starting at 1 and increase
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

}

// File: contracts/Microsponsors.sol

pragma solidity ^0.5.11;


/**
 * Customized for Microsponsors
 * from Open Zeppelin's ERC721Metadata contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Metadata.sol
 */
contract Microsponsors is ERC721 {

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;


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

        super.updateRegistryAddress(registryAddress);

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

}
