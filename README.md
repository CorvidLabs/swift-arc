# SwiftARC

[![macOS](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-arc/macOS.yml?label=macOS&branch=main)](https://github.com/CorvidLabs/swift-arc/actions/workflows/macOS.yml)
[![Ubuntu](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-arc/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/CorvidLabs/swift-arc/actions/workflows/ubuntu.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-arc)](https://github.com/CorvidLabs/swift-arc/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-arc)](https://github.com/CorvidLabs/swift-arc/releases)

> **Pre-1.0 Notice**: This library is under active development. The API may change between minor versions until 1.0.

A Swift package for working with Algorand ARC (Algorand Request for Comments) NFT metadata standards, built with Swift 6 strict concurrency and following modern Swift design patterns.

## Features

- **ARC-3**: Algorand Standard Asset Parameters Conventions for Fungible and Non-Fungible Tokens
- **ARC-19**: Templated URI for NFT Metadata with IPFS CID encoding
- **ARC-69**: On-Chain NFT Metadata with media fragments
- **IPFS Support**: Parse and manipulate IPFS URLs and Content Identifiers (CIDs)
- **Type-Safe**: Leverage Swift's type system for compile-time safety
- **Sendable**: Full Swift 6 concurrency support with Sendable conformance
- **Fluent Builders**: Ergonomic builder patterns for creating metadata
- **Comprehensive Validation**: Built-in validation for all ARC standards

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 15.0+

## Installation

Add swift-arc to your Package.swift dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-arc.git", from: "0.1.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "ARC", package: "swift-arc")
    ]
)
```

## Usage

### ARC-3: Standard NFT Metadata

```swift
import ARC

// Using the builder
let metadata = ARC3Builder(name: "My NFT")
    .description("A beautiful NFT")
    .image("ipfs://QmYourCID/image.png", mimeType: "image/png")
    .property(key: "rarity", value: "legendary")
    .property(key: "level", value: 100)
    .build()

// Validate the metadata
let result = metadata.validate()
if result.isValid {
    print("Metadata is valid!")
} else {
    print("Validation errors: \(result.failures)")
}

// Encode to JSON
let json = try metadata.toJSON()
```

### ARC-19: Templated IPFS URIs

```swift
import ARC

// Create a template from an IPFS CID
let template = try ARC19Builder()
    .cid("QmYourCID")
    .pathTemplate("/metadata/{id}")
    .validated()

// Resolve for a specific asset
let resolved = try template.resolve(assetID: 12345)
// Returns: "ipfs://QmYourCID/metadata/12345"

// Get the reserve address (for on-chain storage)
print(template.reserveAddress)
```

### ARC-69: On-Chain Metadata

```swift
import ARC

// Using the builder with media fragments
let metadata = ARC69Builder()
    .description("On-chain NFT")
    .image(url: "https://example.com/image.png")  // Automatically adds #i fragment
    .property(key: "collection", value: "Genesis")
    .build()

// Generate compact JSON for on-chain storage
let compactJSON = try metadata.toCompactJSONString()
```

### IPFS URLs

```swift
import ARC

// Parse IPFS URLs
let url = try IPFSUrl(string: "ipfs://QmYourCID/path/to/file.json")
print(url.cid.toString())  // "QmYourCID"
print(url.path)            // "/path/to/file.json"

// Convert to HTTP gateway URL
let gatewayURL = url.toGatewayURL()
// Returns: "https://gateway.pinata.cloud/ipfs/QmYourCID/path/to/file.json"

// Template resolution
let templateUrl = try IPFSUrl(
    string: "template-ipfs://QmYourCID/metadata/{id}"
)
let resolved = templateUrl.resolveARC19Template(assetID: 123)
```

### Property Values

Property values can be strings, numbers, or nested objects:

```swift
let metadata = ARC3Builder(name: "NFT")
    .property(key: "text", value: .text("value"))
    .property(key: "number", value: .numeric(42))
    .property(key: "nested", value: .dictionary([
        "strength": .numeric(100),
        "element": .text("fire")
    ]))
    .build()
```

### Validation

All metadata types support validation:

```swift
let result = metadata.validate()

if result.isValid {
    print("Valid!")
} else {
    for failure in result.failures {
        print("\(failure.field): \(failure.message)")
    }

    for warning in result.warnings {
        print("Warning - \(warning.field): \(warning.message)")
    }
}
```

## Architecture

The package follows protocol-oriented design with clear separation of concerns:

- **Core**: Base protocols and validation infrastructure
- **ARC3**: Standard NFT metadata with off-chain storage
- **ARC19**: Templated URIs with CID encoding in reserve addresses
- **ARC69**: On-chain metadata with media fragment support
- **IPFS**: IPFS URL and CID utilities

All public types are Sendable and designed for concurrent use.

## Standards

### ARC-3
Implements the [ARC-3 specification](https://github.com/algorandfoundation/ARCs/blob/main/ARCs/arc-0003.md) for NFT metadata with:
- Asset name and description
- Images, animations, and external URLs
- Properties and extra metadata
- Integrity hashes (SHA-256, SHA-384, SHA-512)
- Localization support

### ARC-19
Implements the [ARC-19 specification](https://github.com/algorandfoundation/ARCs/blob/main/ARCs/arc-0019.md) for templated metadata URIs with:
- CID encoding in reserve addresses
- Template variable resolution
- Asset ID substitution

### ARC-69
Implements the [ARC-69 specification](https://github.com/algorandfoundation/ARCs/blob/main/ARCs/arc-0069.md) for on-chain metadata with:
- Standard field: "arc69"
- Media fragments (#i, #v, #a, #p, #h)
- Compact JSON encoding
- Properties and custom fields

## Testing

The package includes comprehensive tests (98 tests) covering all functionality:

```bash
swift test
```

## License

MIT License - Copyright (c) 2024 Leif

## Dependencies

- [swift-algorand](https://github.com/CorvidLabs/swift-algorand) - Algorand SDK
- [swift-pinata](https://github.com/CorvidLabs/swift-pinata) - Pinata IPFS client
- [swift-crypto](https://github.com/apple/swift-crypto) - Apple's Swift Crypto
