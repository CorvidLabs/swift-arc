---
spec: arc.spec.md
---

## Automated Testing

The native XCTest target contains 115 methods across four files. One pre-existing method has no assertion and is not
counted as requirement evidence; the other 114 exercise implemented behavior.

| Test File | Methods | Meaningful Evidence |
|-----------|--------:|--------------------:|
| `Tests/ARCTests/ARC19Tests.swift` | 34 | 34 |
| `Tests/ARCTests/ARC3Tests.swift` | 22 | 22 |
| `Tests/ARCTests/ARC69Tests.swift` | 37 | 37 |
| `Tests/ARCTests/IPFSTests.swift` | 22 | 21 |

The configured verification command runs `fledge lanes run verify`, which executes `swift build` and `swift test`.

## Requirement Evidence

| Requirements | Native Evidence |
|--------------|-----------------|
| `REQ-arc-001`, `REQ-arc-002`, `REQ-arc-012` | ARC-3 and ARC-69 validation, properties, JSON, warnings, and error tests. |
| `REQ-arc-003`, `REQ-arc-004` | `ARC3Tests` builder, validation, localization, integrity, URL, MIME, and JSON tests. |
| `REQ-arc-005`, `REQ-arc-006` | `ARC19Tests` placeholder parsing, codec, reserve-address, builder, validation, resolution, and Codable tests. |
| `REQ-arc-007`, `REQ-arc-008` | Meaningful `IPFSTests` CID construction/error and IPFS parsing, rendering, resolution, Codable, and gateway tests; ARC-19 CID round trips. |
| `REQ-arc-009`, `REQ-arc-010`, `REQ-arc-011` | `ARC69Tests` metadata, builder, fragment, MIME, validation, warning, and JSON tests. |

## Manual Review

Compare the companion against public declarations in every listed source file, verify the parser export inventory,
and confirm that `git diff` contains no changes under `Sources/` or `Tests/`.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Empty ARC-3 name | Blocking validation failure for `name`. |
| ARC-3 default locale absent from locales | Valid result with a localization warning. |
| Unsupported ARC-19 version, codec, or hash | Typed invalid-URL error. |
| Reserve address has invalid checksum when validation is requested | Typed invalid-reserve-address error. |
| CID hash is not 32 bytes | Rendering falls back to the version prefix; ARC-19 reserve encoding rejects it. |
| IPFS URL lacks a supported scheme or CID | Typed invalid-URL or invalid-CID error. |
| ARC-69 media fragment disagrees with MIME type | Valid result with a warning. |
| ARC-69 has no content fields | Valid result with a warning. |
