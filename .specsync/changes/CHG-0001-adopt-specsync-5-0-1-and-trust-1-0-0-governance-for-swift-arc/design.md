---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-arc
artifact: design
---

# Design

Preserve every existing workflow unchanged. Add a macOS trust job on every pull
request and main push so conditional Apple-platform targets are included. Trust
uses full history and its immutable v1.0.0 commit, delegates build and tests to
Fledge, blocks risk, uses progressive provenance, and leaves Pages independent.
