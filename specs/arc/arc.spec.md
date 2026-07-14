---
module: arc
version: 3
status: active
files:
  - Sources/ARC/ARC19/ARC19Builder.swift
  - Sources/ARC/ARC19/ARC19CID.swift
  - Sources/ARC/ARC19/ARC19Template.swift
  - Sources/ARC/Core/PropertyValue.swift
  - Sources/ARC/Core/ARCMetadata.swift
  - Sources/ARC/Core/ARCStandard.swift
  - Sources/ARC/Core/ARCValidation.swift
  - Sources/ARC/ARC3/ARC3Builder.swift
  - Sources/ARC/ARC3/ARC3Validator.swift
  - Sources/ARC/ARC3/ARC3Metadata.swift
  - Sources/ARC/IPFS/IPFSUrl.swift
  - Sources/ARC/IPFS/CID.swift
  - Sources/ARC/ARC69/ARC69Validator.swift
  - Sources/ARC/ARC69/ARC69Builder.swift
  - Sources/ARC/ARC69/ARC69Metadata.swift
  - Sources/ARC/ARC69/ARC69MediaFragment.swift
  - Sources/ARC/ARCError.swift

db_tables: []
depends_on: []
---

# ARC

## Purpose

The `ARC` module models and validates Algorand ARC-3 off-chain metadata, ARC-19 templated IPFS addressing, and
ARC-69 on-chain metadata. It owns fluent metadata builders, validation results, structured property values, CID
encoding, Algorand reserve-address conversion, IPFS URL manipulation, and JSON serialization. It does not fetch or
pin content, submit Algorand transactions, persist metadata, or publish assets.

## Public API

### Export Inventory

Each parser-visible export is listed independently so contract coverage is explicit.

| Export | Contract area |
|--------|---------------|
| `ARCMetadata` | Shared metadata protocol. |
| `PropertyMetadata` | Property-bearing metadata protocol. |
| `LocalizableMetadata` | Localizable metadata protocol. |
| `LocalizationInfo` | Localization value. |
| `ARCStandard` | Standard dispatch protocol. |
| `ARC3` | ARC-3 namespace. |
| `ARC19` | ARC-19 namespace. |
| `ARC69` | ARC-69 namespace. |
| `ValidationResult` | Validation aggregate. |
| `ARCValidator` | Validator protocol. |
| `BaseValidator` | Shared validator helpers. |
| `PropertyValue` | Recursive JSON property value. |
| `ARCError` | Typed library error. |
| `ValidationFailure` | Field validation detail. |
| `ARC3Builder` | ARC-3 value builder. |
| `ARC3Validator` | ARC-3 validator. |
| `ARC3Metadata` | ARC-3 metadata value. |
| `ARC19Builder` | ARC-19 template builder. |
| `ARC19CID` | ARC-19 CID namespace. |
| `TemplateParams` | ARC-19 placeholder parameters. |
| `ARC19Template` | ARC-19 template value. |
| `CID` | IPFS content identifier. |
| `Version` | CID version. |
| `Codec` | CID codec. |
| `IPFSUrl` | IPFS URL value. |
| `Scheme` | IPFS URL scheme. |
| `ARC69Builder` | ARC-69 value builder. |
| `ARC69Validator` | ARC-69 validator. |
| `ARC69Metadata` | ARC-69 metadata value. |
| `ARC69MediaFragment` | ARC-69 media fragment. |
| `Metadata` | Associated standard metadata type. |
| `init` | Public value initialization and Codable/literal decoding. |
| `validate` | Metadata and standard validation. |
| `properties` | Metadata property map and builder replacement. |
| `localization` | Localization value and builder setter. |
| `uri` | Localization resource URI. |
| `defaultLocale` | Default localization tag. |
| `locales` | Available localization tags. |
| `integrity` | Optional localization integrity. |
| `standardNumber` | Numeric ARC identifier. |
| `standardName` | Human-readable ARC identifier. |
| `isValid` | Blocking-validity result. |
| `failures` | Blocking validation details. |
| `warnings` | Non-blocking validation details. |
| `valid` | Empty successful result. |
| `invalid` | Failure-separating result factory. |
| `failure` | Single blocking result factory. |
| `warning` | Single warning result factory and severity case. |
| `combine` | Array result combination. |
| `combined` | Pairwise result combination. |
| `validateURL` | General URL validation. |
| `validateNotEmpty` | Required non-empty text validation. |
| `validatePresent` | Required optional value validation. |
| `validatePattern` | Regex validation. |
| `validateIPFSURL` | IPFS scheme validation. |
| `validateMediaType` | MIME syntax validation. |
| `string` | String property case. |
| `number` | Numeric property case. |
| `object` | Nested-object property case. |
| `text` | String property factory. |
| `numeric` | Double property factory. |
| `integer` | Integer property factory. |
| `dictionary` | Nested-object property factory. |
| `encode` | Codable encoding. |
| `invalidMetadata` | Metadata error case. |
| `invalidURL` | URL error case. |
| `invalidCID` | CID error case. |
| `invalidReserveAddress` | Reserve-address error case. |
| `invalidPropertyValue` | Property error case. |
| `validationFailed` | Validation error case. |
| `encodingFailed` | Encoding error case. |
| `decodingFailed` | Decoding error case. |
| `missingRequiredField` | Missing-field error case. |
| `invalidMediaFragment` | Media-fragment error case. |
| `errorDescription` | Localized error text. |
| `field` | Validation field. |
| `message` | Validation message. |
| `severity` | Validation severity. |
| `Severity` | Severity type. |
| `error` | Blocking severity case. |
| `name` | ARC-3 name and builder setter. |
| `description` | Metadata description and string description. |
| `image` | ARC-3 image and ARC-69 image helper. |
| `imageIntegrity` | ARC-3 image integrity. |
| `imageMimeType` | ARC-3 image MIME type. |
| `externalUrl` | External resource URL and builder setter. |
| `externalUrlIntegrity` | ARC-3 external URL integrity. |
| `externalUrlMimeType` | ARC-3 external URL MIME type. |
| `animationUrl` | ARC-3 animation URL and builder setter. |
| `animationUrlIntegrity` | ARC-3 animation integrity. |
| `animationUrlMimeType` | ARC-3 animation MIME type. |
| `property` | Single property builder setter. |
| `extra` | ARC-3 extension values and builder setter. |
| `build` | Metadata construction. |
| `validated` | Validating builder construction. |
| `toBuilder` | Metadata-to-builder conversion. |
| `from` | JSON data or text decoding. |
| `toJSON` | JSON data encoding. |
| `toJSONString` | JSON text encoding. |
| `cid` | Builder, template, and URL CID. |
| `ipfsUrl` | ARC-19 builder IPFS input. |
| `pathTemplate` | ARC-19 builder path template. |
| `reserveAddress` | ARC-19 reserve address. |
| `version` | CID version value. |
| `codec` | CID codec value. |
| `hashAlgorithm` | ARC-19 hash algorithm. |
| `v0DagPB` | Default CIDv0 dag-pb parameters. |
| `v1Raw` | Default CIDv1 raw parameters. |
| `parseTemplateParams` | Placeholder parser. |
| `extractCID` | Reserve-address CID extraction. |
| `encodeToReserveAddress` | CID reserve-address encoding. |
| `templateUrl` | ARC-19 template text. |
| `templateParams` | Parsed ARC-19 parameters. |
| `resolve` | ARC-19 text resolution. |
| `resolveToIPFSUrl` | ARC-19 typed URL resolution. |
| `hash` | CID digest bytes. |
| `v0` | CID version-zero case. |
| `v1` | CID version-one case. |
| `raw` | Raw codec case. |
| `dagPB` | dag-pb codec case. |
| `dagCBOR` | dag-cbor codec case. |
| `dagJSON` | dag-json codec case. |
| `toString` | CID and IPFS text rendering. |
| `templateString` | ARC-19 codec text. |
| `scheme` | IPFS URL scheme value. |
| `path` | IPFS URL path. |
| `ipfs` | IPFS scheme case. |
| `templateIPFS` | Template-IPFS scheme case. |
| `toGatewayURL` | HTTP gateway conversion. |
| `resolveTemplate` | General path-variable resolution. |
| `resolveARC19Template` | Asset-ID path resolution. |
| `standard` | ARC-69 standard marker. |
| `mediaUrl` | ARC-69 media URL and builder setter. |
| `mimeType` | ARC-69 MIME type and builder setter. |
| `mediaFragment` | Parsed ARC-69 fragment. |
| `media` | MIME-aware ARC-69 media setter. |
| `video` | ARC-69 video helper and fragment case. |
| `audio` | ARC-69 audio helper and fragment case. |
| `pdfDocument` | ARC-69 PDF helper. |
| `htmlDocument` | ARC-69 HTML helper. |
| `toCompactJSONString` | Compact ARC-69 JSON encoding. |
| `pdf` | ARC-69 PDF fragment case. |
| `html` | ARC-69 HTML fragment case. |
| `identifier` | Media fragment text. |
| `mimeTypePrefix` | Fragment MIME mapping. |
| `extract` | Media fragment extraction. |
| `removeFragment` | Media fragment removal. |
| `apply` | Media fragment replacement. |
| `matches` | MIME compatibility test. |
| `infer` | MIME-to-fragment inference. |

## Invariants

1. Public metadata, validation, CID, URL, builder, error, and fragment values remain `Sendable` where declared.
2. ARC-3 requires a non-empty name; optional URLs, MIME types, integrity strings, and localization are validated only
   when present, and a missing default locale in the locale list is a warning.
3. ARC-19 placeholders contain exactly version, codec, reserve, and `sha2-256` fields; reserve-address payloads use a
   32-byte CID hash plus the Algorand four-byte checksum.
4. ARC-19 template resolution substitutes both the CID placeholder and `{id}` without network access.
5. CIDv0 uses dag-pb with a SHA2-256 multihash; CIDv1 preserves its supported codec and emits lowercase Base32.
6. IPFS URLs accept only `ipfs://` and `template-ipfs://`, require a CID, retain an optional slash-prefixed path, and
   resolve only variables present in that path.
7. ARC-69 requires `standard == "arc69"`; fragment/MIME disagreement and empty content are warnings, while invalid
   URLs, MIME types, standards, and fragments are failures.
8. Builders are value-semantic: mutating methods return a modified copy, `build` creates metadata, and `validated`
   throws `ARCError.validationFailed` only when the resulting validation is not valid.

## Behavioral Examples

### Scenario: Build validated ARC-3 metadata

- **Given** a non-empty name and valid optional URL, MIME, integrity, property, and localization fields
- **When** `ARC3Builder.validated()` is called
- **Then** it returns equivalent `ARC3Metadata` that round-trips through JSON

### Scenario: Resolve an ARC-19 asset URL

- **Given** a supported CID encoded in an Algorand reserve address and a template containing `{id}`
- **When** `ARC19Template.resolve(assetID:)` is called
- **Then** the placeholder becomes the CID, `{id}` becomes the decimal asset identifier, and the result uses `ipfs://`

### Scenario: Build ARC-69 media metadata

- **Given** a video URL and `video/mp4` MIME type
- **When** `ARC69Builder.media(url:mimeType:)` builds metadata
- **Then** the URL carries `#v`, the MIME type is retained, and validation succeeds

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Unsupported or malformed CID text | Throw `ARCError.invalidCID` with the parsing reason. |
| Unsupported ARC-19 placeholder version, codec, hash, or shape | Throw `ARCError.invalidURL`. |
| Invalid reserve-address characters, length, checksum, or payload size | Throw `ARCError.invalidReserveAddress`. |
| Builder lacks its required CID | Throw `ARCError.missingRequiredField("cid")`. |
| `validated()` receives blocking validation failures | Throw `ARCError.validationFailed` carrying those failures. |
| JSON text cannot become UTF-8 or encoded data cannot become text | Throw the declared decoding or encoding error. |
| ARC-69 URL fragment is unknown or not one character | Throw `ARCError.invalidMediaFragment` from direct fragment extraction. |

## Dependencies

### Consumes

| Module | What is used |
|--------|-------------|
| Swift standard library and Foundation | Codable, Data, URL parsing, regex validation, literals, collections, and `Sendable`. |
| Crypto | SHA-512/256 used for Algorand reserve-address checksums. |
| Algorand | Package-level dependency supporting the ARC ecosystem; this module implements its own reserve encoding. |
| Pinata | Package-level IPFS dependency; this module exposes URL conversion but performs no Pinata requests. |

### Consumed By

| Module | What is used |
|--------|-------------|
| Package clients | The `ARC` library product and its metadata, builder, validation, CID, and IPFS APIs. |

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Documented the existing public API and behavior for SpecSync 5.0.1 without changing implementation. |
| 2026-07-14 | CHG-0002-document-the-existing-swift-arc-api-at-complete-specsync-coverage: Document the existing Swift ARC API at complete SpecSync coverage |
