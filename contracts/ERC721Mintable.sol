pragma solidity ^0.5.0;

import "./ERC721.sol";
import "./MinterRole.sol";

/**
 * @title ERC721Mintable
 * @dev ERC721 minting logic.
 */
contract ERC721Mintable is ERC721, MinterRole {
    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }

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
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {
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
    function safeMint(address to, uint256 tokenId) public onlyMinter returns (bool) {
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
    function safeMint(address to, uint256 tokenId, bytes memory _data) public onlyMinter returns (bool) {
        _safeMint(to, tokenId, _data);
        return true;
    }

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
    function safeMintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }
}
