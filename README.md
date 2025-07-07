# Royaltix NFT Marketplace

A decentralized NFT marketplace smart contract built on the Stacks blockchain using Clarity smart contract language. Royaltix enables users to mint, list, buy, and sell NFTs with built-in royalty support for creators.

## Features

- **NFT Minting**: Create new NFTs with custom metadata and royalty settings
- **Marketplace Functionality**: List NFTs for sale and purchase them directly
- **Creator Royalties**: Automatic royalty distribution to original creators on secondary sales
- **Ownership Management**: Transfer contract ownership with proper validation
- **Secure Operations**: Built-in safety checks and error handling

## Contract Overview

The Royaltix contract implements a complete NFT marketplace with the following core components:

### NFT Asset
- **Token Standard**: SIP-009 compliant Non-Fungible Token
- **Token Name**: `royaltix-nft`
- **Token ID**: Unique integer identifier for each NFT

### Data Structures

#### State Variables
- `royaltix-owner`: Contract owner principal
- `royaltix-next-id`: Counter for generating unique token IDs

#### Maps
- `royaltix-tokens`: Stores NFT metadata (owner, creator, URI, royalty)
- `royaltix-listings`: Stores marketplace listings (price, seller)

## Public Functions

### Minting
```clarity
(royaltix-mint (uri (string-ascii 256)) (royalty uint))
```
- Mints a new NFT with specified metadata URI and royalty percentage
- Royalty must be ≤ 1000 (10% maximum)
- Returns the new token ID

### Marketplace Operations

#### List NFT
```clarity
(royaltix-list (token-id uint) (price uint))
```
- Lists an NFT for sale at specified price
- Only token owner can list
- Price must be greater than 0

#### Buy NFT
```clarity
(royaltix-buy (token-id uint))
```
- Purchases a listed NFT
- Automatically handles royalty distribution
- Transfers ownership to buyer

#### Cancel Listing
```clarity
(royaltix-cancel-listing (token-id uint))
```
- Removes NFT from marketplace
- Only the seller can cancel their listing

### Administrative Functions

#### Transfer Ownership
```clarity
(transfer-royaltix-ownership (new-owner principal))
```
- Transfers contract ownership
- Only current owner can execute
- New owner must be different from current owner

## Read-Only Functions

### Token Information
```clarity
(royaltix-get-token (token-id uint))
```
Returns token details including owner, creator, URI, and royalty information.

### Listing Information
```clarity
(royaltix-get-listing (token-id uint))
```
Returns marketplace listing details including price and seller.

### Contract Owner
```clarity
(get-royaltix-owner)
```
Returns the current contract owner.

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Operation requires contract owner |
| u101 | `err-not-token-owner` | Operation requires token owner |
| u102 | `err-listing-not-found` | Listing does not exist |
| u103 | `err-invalid-price` | Invalid price (must be > 0) |
| u104 | `err-invalid-token-id` | Invalid or non-existent token ID |
| u105 | `err-invalid-uri` | Invalid URI (cannot be empty) |
| u106 | `err-invalid-royalty` | Invalid royalty (must be ≤ 1000) |
| u107 | `err-invalid-new-owner` | New owner must be different from current |

## Royalty System

The contract implements a creator royalty system where:
- Royalties are set during minting (0-10% of sale price)
- Royalties are expressed in basis points (1000 = 10%)
- On each sale, royalties are automatically paid to the original creator
- Remaining amount goes to the seller

### Royalty Calculation
```
royalty_amount = (price * royalty) / 10000
seller_amount = price - royalty_amount
```

## Security Features

- **Ownership Validation**: All operations verify proper ownership
- **Input Validation**: Parameters are validated before execution
- **Safe Transfers**: Uses built-in STX and NFT transfer functions
- **Error Handling**: Comprehensive error codes and assertions
- **Reentrancy Protection**: Atomic operations prevent manipulation

## Usage Examples

### Minting an NFT
```clarity
(contract-call? .royaltix royaltix-mint "https://example.com/metadata.json" u500)
;; Mints NFT with 5% royalty
```

### Listing for Sale
```clarity
(contract-call? .royaltix royaltix-list u1 u1000000)
;; Lists token #1 for 1 STX (1,000,000 microSTX)
```

### Purchasing an NFT
```clarity
(contract-call? .royaltix royaltix-buy u1)
;; Purchases token #1 from marketplace
```

## Development

### Prerequisites
- Stacks blockchain environment
- Clarity smart contract compiler
- Clarinet (recommended for testing)

### Testing
The contract includes comprehensive assertions and error handling. Test all functions with:
- Valid and invalid inputs
- Edge cases (empty URIs, zero prices, etc.)
- Ownership scenarios
- Royalty calculations

### Deployment
Deploy to Stacks blockchain using your preferred deployment method:
- Clarinet
- Stacks CLI
- Web-based deployment tools


