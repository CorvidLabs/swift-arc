# ARC semantic delta

## ADDED

### REQUIREMENT REQ-arc-001

Validation results SHALL preserve blocking failures and non-blocking warnings separately, compute validity from
their inputs, and combine results without discarding field, message, severity, or ordering information.

Acceptance Criteria

- `.valid`, `.failure`, `.warning`, `.invalid`, `combine`, and `combined` produce the declared validity and arrays.
- `.invalid` routes error-severity values to failures and warning-severity values to warnings.
- Base validators reject missing values, malformed URLs, patterns, unsupported IPFS schemes, and malformed MIME types.

### REQUIREMENT REQ-arc-002

`PropertyValue` SHALL preserve string, numeric, and recursively nested object values across Codable and supported
Swift literal conversions.

Acceptance Criteria

- Text, numeric, integer, dictionary, and matching literal entry points produce the corresponding enum case.
- JSON strings, numbers, and objects decode and re-encode without changing their represented value.
- Unsupported JSON shapes fail decoding rather than being coerced.

### REQUIREMENT REQ-arc-003

ARC-3 metadata and its builder SHALL preserve the name, optional description, image, external URL, animation URL,
integrity, MIME, property, extra, and localization fields and round-trip them with the declared JSON keys.

Acceptance Criteria

- Builder calls return modified copies and `build` emits the accumulated values.
- `from(json:)`, `toJSON`, and `toJSONString` preserve supported ARC-3 fields.
- `toBuilder` exposes the existing metadata values through the builder surface.

### REQUIREMENT REQ-arc-004

ARC-3 validation SHALL require a non-empty name and validate each present URL, MIME type, integrity value, and
localization record according to the implemented formats.

Acceptance Criteria

- HTTP and supported IPFS URLs validate, while malformed URLs fail their source field.
- MIME values use `type/subtype`; integrity values use sha256, sha384, or sha512 followed by Base64 data.
- Localization requires URI, default locale, and a non-empty locale list; a missing default-locale member warns.
- `ARC3Builder.validated` returns valid metadata and throws `validationFailed` for blocking failures.

### REQUIREMENT REQ-arc-005

ARC-19 CID utilities SHALL parse the five-part `{ipfscid:version:codec:reserve:sha2-256}` placeholder and translate
32-byte CID hashes to and from Algorand reserve addresses.

Acceptance Criteria

- Versions 0 and 1, raw, dag-pb, dag-cbor, and dag-json codecs, and sha2-256 parse as declared.
- Unsupported placeholder shapes, versions, codecs, and hash algorithms throw typed errors.
- Reserve extraction can optionally validate the four-byte SHA-512/256 checksum.
- Encoding and extracting a supported CID preserves its hash, requested version, and codec.

### REQUIREMENT REQ-arc-006

ARC-19 templates and builders SHALL create, validate, serialize, and resolve template-IPFS URLs using their reserve
address, parsed CID parameters, optional path template, and decimal asset identifier.

Acceptance Criteria

- A builder without a CID throws `missingRequiredField`; otherwise it derives a reserve address unless supplied.
- Template construction requires the template scheme and CID placeholder and derives the CID from the reserve address.
- Resolution replaces the CID placeholder and `{id}` and can return either text or `IPFSUrl`.
- Validation rejects invalid scheme/address/placeholder and warns when `{id}` is absent.
- Codable preserves `template_url` and `reserve_address` and validates during decoding.

### REQUIREMENT REQ-arc-007

`CID` SHALL parse and emit CIDv0 Base58 SHA2-256 dag-pb values and CIDv1 Base32 or Base58 values using the supported
raw, dag-pb, dag-cbor, and dag-json codecs.

Acceptance Criteria

- CIDv0 parsing requires the multihash prefix and records version 0 with dag-pb.
- CIDv1 parsing requires version byte 1, a supported codec varint, and a 32-byte SHA2-256 multihash.
- Rendering a valid 32-byte hash round-trips the version, codec, and hash.
- Invalid prefixes, alphabets, versions, codecs, multihashes, and lengths throw `invalidCID`.

### REQUIREMENT REQ-arc-008

`IPFSUrl` SHALL parse only IPFS and template-IPFS schemes, retain its CID and optional path, render deterministic URL
and gateway strings, resolve path variables, and preserve the string form through Codable and descriptions.

Acceptance Criteria

- Parsing requires `://`, a supported scheme, a non-empty CID, and a valid CID representation.
- Rendering retains the scheme and slash-prefixed path; gateway rendering uses `/ipfs/<cid>`.
- Variable resolution replaces matching `{key}` tokens without mutating the original value.
- Lossless-string and Codable initialization fail for malformed input and preserve valid input.

### REQUIREMENT REQ-arc-009

ARC-69 metadata and its builder SHALL preserve the `arc69` standard, optional content fields, properties, MIME type,
and fragment-aware media helpers and SHALL provide sorted and compact JSON representations.

Acceptance Criteria

- Builder methods return modified copies, and media helpers apply the fragment inferred from MIME type.
- Image, video, audio, PDF, and HTML helpers apply their declared default MIME types and fragments.
- JSON data and strings preserve snake-case keys; compact output contains no formatting whitespace.
- `ARC69Builder.validated` throws only for blocking validation failures.

### REQUIREMENT REQ-arc-010

ARC-69 media fragments SHALL parse, remove, replace, describe, infer, and compare image, video, audio, PDF, and HTML
fragments using their declared single-character identifiers and MIME mappings.

Acceptance Criteria

- `#i`, `#v`, `#a`, `#p`, and `#h` map to the corresponding cases and descriptions.
- Extraction returns nil when no fragment exists and rejects unknown or multi-character fragments.
- Applying a fragment replaces any existing fragment; inference and matching use the declared MIME prefixes or values.

### REQUIREMENT REQ-arc-011

ARC-69 validation SHALL require the exact `arc69` standard, validate present URLs and MIME types, reject invalid media
fragments, and report content absence or fragment/MIME disagreement as warnings.

Acceptance Criteria

- A different standard, malformed URL, malformed MIME type, or invalid present fragment produces a failure.
- Fragment and MIME disagreement preserves validity while adding a warning.
- Metadata with none of description, external URL, media URL, or properties preserves validity while adding a warning.

### REQUIREMENT REQ-arc-012

Public ARC contracts SHALL preserve their declared standard dispatch, typed diagnostics, Codable representations, and
`Sendable` value semantics without performing network, persistence, or transaction side effects.

Acceptance Criteria

- ARC-3, ARC-19, and ARC-69 expose standard numbers, names, associated metadata, and matching validation dispatch.
- `ARCError.errorDescription` identifies its case and associated diagnostic content.
- `ValidationFailure` preserves field, message, and severity with error as the default severity.
- Metadata, builders, CID, URL, validation, error, localization, property, and fragment values retain declared
  concurrency conformance and deterministic local behavior.
