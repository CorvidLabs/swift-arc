---
change: CHG-0002-document-the-existing-swift-arc-api-at-complete-specsync-coverage
artifact: testing
---

# Testing

Verification uses `fledge lanes run verify`, which builds the Swift package and executes all 115 XCTest methods.
Requirement evidence intentionally excludes the pre-existing no-assertion `testCIDFromStringV0` method.

| Requirement evidence | Native test evidence |
|----------------------|----------------------|
| `REQ-arc-001` | `ARC3Tests.swift` and `ARC69Tests.swift`: blocking failures, warnings, and combined validation. |
| `REQ-arc-002` | `ARC3Tests.swift` and `ARC69Tests.swift`: literal properties and JSON round trips. |
| `REQ-arc-003` | `ARC3Tests.swift`: metadata, builders, properties, localization, and JSON. |
| `REQ-arc-004` | `ARC3Tests.swift`: name, URL, IPFS, MIME, integrity, and localization validation. |
| `REQ-arc-005` | `ARC19Tests.swift`: placeholder parameters, codecs, reserve addresses, checksums, and CID round trips. |
| `REQ-arc-006` | `ARC19Tests.swift`: builders, template validation, asset resolution, typed URLs, and Codable. |
| `REQ-arc-007` | `ARC19Tests.swift` and meaningful `IPFSTests.swift` methods: CID construction, round trips, and errors. |
| `REQ-arc-008` | Meaningful `IPFSTests.swift` methods: URL parsing, rendering, gateways, variables, Codable, and errors. |
| `REQ-arc-009` | `ARC69Tests.swift`: metadata, all builder helpers, properties, validation, and JSON forms. |
| `REQ-arc-010` | `ARC69Tests.swift`: fragment extraction, removal, replacement, matching, inference, and errors. |
| `REQ-arc-011` | `ARC69Tests.swift`: standards, URLs, MIME types, fragment mismatch, and content warnings. |
| `REQ-arc-012` | All four native test files: dispatch, errors, Codable values, equality, and deterministic behavior. |

Strict SpecSync must cover all seventeen implementation files and all 150 parser-visible exports. Trust doctor and
committed-range verification must pass, and the migration diff must not modify `Sources/` or `Tests/`.
