---
spec: arc.spec.md
---

## Completed Adoption Work

- [x] Inventory all seventeen Swift implementation files using their case-sensitive paths.
- [x] Document every parser-visible public export and the existing ownership boundary.
- [x] Define stable source-backed requirements for ARC-3, ARC-19, ARC-69, CID, IPFS, validation, and errors.
- [x] Map requirements only to native tests that contain meaningful assertions.
- [x] Preserve package source, tests, manifest, and existing platform and documentation workflows.

## Known Test Debt

- `IPFSTests.testCIDFromStringV0` declares an unused value and performs no assertion. It is pre-existing,
  outside this governance-only migration, and intentionally excluded from evidence.

## Review Record

- Product behavior: unchanged.
- QA evidence: native Fledge build/test lane plus strict SpecSync and Trust verification.
- Development scope: canonical documentation and governance configuration only.
