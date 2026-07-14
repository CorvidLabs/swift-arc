---
spec: arc.spec.md
---

## Key Decisions

- Model ARC-3, ARC-19, and ARC-69 in one Swift library while keeping standard-specific builders and validators.
- Represent arbitrary metadata properties with a recursive Codable enum limited to strings, numbers, and objects.
- Keep validation non-throwing through `ValidationResult`; builder validation converts blocking failures to
  `ARCError.validationFailed`.
- Implement CID and reserve-address conversion locally and deterministically; network, storage, and transaction
  behavior remain outside this package.

## Files to Read First

- `Sources/ARC/Core/ARCMetadata.swift` and `ARCValidation.swift` for shared contracts.
- `Sources/ARC/ARC3/ARC3Metadata.swift`, `ARC19/ARC19Template.swift`, and `ARC69/ARC69Metadata.swift` for standards.
- `Sources/ARC/IPFS/CID.swift` and `IPFSUrl.swift` for content addressing.
- `Tests/ARCTests/ARC3Tests.swift`, `ARC19Tests.swift`, `ARC69Tests.swift`, and `IPFSTests.swift` for behavior.

## Current Status

- Seventeen Swift implementation files build successfully with Swift 6.
- The native XCTest target contains 115 test methods; 114 contain meaningful assertions, while the pre-existing
  `testCIDFromStringV0` method has no assertion and is not used as requirement evidence.
- ARC-3, ARC-19, ARC-69, CID, IPFS URL, validation, Codable, builder, and error paths are implemented.

## Notes

- This companion documents the existing code. It does not assert conformance beyond behavior present in source.
- The package manifest remains authoritative for supported platforms and dependency versions.
