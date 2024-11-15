// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    uint public constant MAX_TOKENS = 1000;
    uint private constant TOKENS_RESERVED = 4;
    uint public price = 1000000000000000;
    uint256 public constant MAX_MINT_PER_TX = 10;

    bool public isSaleActive;
    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    constructor(address initialOwner) ERC721("NFT Name", "SYMBOL") Ownable(initialOwner) {
        transferOwnership(initialOwner);
        baseUri = "https://bafybeib3cmu56u6v4gpnvcifpbf54hvftbgzmzqvjeuxz5zgcta6u4usaq.ipfs.dweb.link?filename=lion1";

        for (uint256 i = 1; i <= TOKENS_RESERVED; ++i) {
            _safeMint(msg.sender, i);
        }

        totalSupply = TOKENS_RESERVED;
    }

    // Public Functions
    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "The sale is currently not Live.");
        require(_numTokens <= MAX_MINT_PER_TX, "You cannot mint that many in one transaction.");
        require(mintedPerWallet[msg.sender] + _numTokens <= MAX_MINT_PER_TX, "You cannot mint that many tokens at once.");

        uint256 newTotalSupply = totalSupply + _numTokens;
        require(newTotalSupply <= MAX_TOKENS, "Exceeds total supply.");
        require(_numTokens * price <= msg.value, "Insufficient funds.");

        for (uint256 i = 1; i <= _numTokens; ++i) {
            uint256 tokenId = totalSupply + i; // Allocate tokenId based on current supply
            _safeMint(msg.sender, tokenId);
        }

        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply = newTotalSupply; // Update after minting
    }

    // Owner-only functions
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function withdrawAll() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = balance * 80 / 100;
        uint256 balanceTwo = balance * 20 / 100;

        (bool successTransferOne, ) = payable(0xd9C8861b775E66D65b57Ef74D26584C17f43A1ac).call{value: balanceOne}("");
        (bool successTransferTwo, ) = payable(0xd9C8861b775E66D65b57Ef74D26584C17f43A1ac).call{value: balanceTwo}("");
        require(successTransferOne && successTransferTwo, "Transfer failed.");
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(tokenId > 0 && tokenId <= totalSupply, "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}
