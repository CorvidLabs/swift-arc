import XCTest
@testable import ARC

final class ARC19Tests: XCTestCase {
    // Helper to create a valid CID string for testing
    private var testCIDString: String {
        CID(version: .v0, codec: .dagPB, hash: Data(repeating: 42, count: 32)).toString()
    }

    // MARK: - Template Creation Tests

    func testTemplateCreation() throws {
        // Create a valid reserve address from a test CID
        let hash = Data(repeating: 1, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        let template = try ARC19Template(
            templateUrl: "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
            reserveAddress: reserveAddress
        )

        XCTAssertEqual(template.templateUrl, "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}")
        XCTAssertEqual(template.reserveAddress, reserveAddress)
    }

    func testTemplateValidation() throws {
        let hash = Data(repeating: 1, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        let template = try ARC19Template(
            templateUrl: "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
            reserveAddress: reserveAddress
        )

        let result = template.validate()
        XCTAssertTrue(result.isValid)
    }

    func testInvalidScheme() throws {
        let hash = Data(repeating: 1, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        XCTAssertThrowsError(
            try ARC19Template(
                templateUrl: "ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
                reserveAddress: reserveAddress
            )
        ) { error in
            if let arcError = error as? ARCError,
               case .invalidURL(let message) = arcError {
                XCTAssertTrue(message.contains("template-ipfs"))
            } else {
                XCTFail("Expected ARCError.invalidURL")
            }
        }
    }

    func testResolveTemplate() throws {
        let hash = Data(repeating: 1, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        let template = try ARC19Template(
            templateUrl: "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
            reserveAddress: reserveAddress
        )

        let resolved = try template.resolve(assetID: 123)

        XCTAssertTrue(resolved.hasPrefix("ipfs://"))
        XCTAssertTrue(resolved.contains("/metadata/123"))
    }

    func testResolveToIPFSUrl() throws {
        let hash = Data(repeating: 1, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        let template = try ARC19Template(
            templateUrl: "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
            reserveAddress: reserveAddress
        )

        let ipfsUrl = try template.resolveToIPFSUrl(assetID: 456)

        XCTAssertEqual(ipfsUrl.scheme, .ipfs)
        XCTAssertTrue(ipfsUrl.path?.contains("456") ?? false)
    }

    // MARK: - Builder Tests

    func testBuilderWithCID() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)

        let template = try ARC19Builder()
            .cid(cid)
            .pathTemplate("/metadata/{id}")
            .build()

        XCTAssertTrue(template.templateUrl.contains("/metadata/{id}"))
    }

    func testBuilderWithCIDString() throws {
        let template = try ARC19Builder()
            .cid(testCIDString)
            .build()

        XCTAssertTrue(template.templateUrl.hasPrefix("template-ipfs://"))
    }

    func testBuilderWithIPFSUrl() throws {
        let ipfsUrl = try IPFSUrl(string: "ipfs://\(testCIDString)/metadata.json")

        let template = try ARC19Builder()
            .ipfsUrl(ipfsUrl)
            .build()

        XCTAssertNotNil(template.reserveAddress)
    }

    func testBuilderWithIPFSUrlString() throws {
        let template = try ARC19Builder()
            .ipfsUrl("ipfs://\(testCIDString)")
            .build()

        XCTAssertTrue(template.templateUrl.hasPrefix("template-ipfs://"))
    }

    func testBuilderDefaultPathTemplate() throws {
        let template = try ARC19Builder()
            .cid(testCIDString)
            .build()

        XCTAssertTrue(template.templateUrl.contains("/{id}"))
    }

    func testBuilderCustomPathTemplate() throws {
        let template = try ARC19Builder()
            .cid(testCIDString)
            .pathTemplate("/nft/{id}/metadata.json")
            .build()

        XCTAssertTrue(template.templateUrl.contains("/nft/{id}/metadata.json"))
    }

    func testBuilderValidated() throws {
        let template = try ARC19Builder()
            .cid(testCIDString)
            .validated()

        let result = template.validate()
        XCTAssertTrue(result.isValid)
    }

    func testBuilderMissingCID() {
        XCTAssertThrowsError(
            try ARC19Builder().build()
        ) { error in
            guard let arcError = error as? ARCError else {
                XCTFail("Expected ARCError")
                return
            }
            if case .missingRequiredField(let field) = arcError {
                XCTAssertEqual(field, "cid")
            } else {
                XCTFail("Expected missingRequiredField error")
            }
        }
    }

    // MARK: - CID Extraction Tests

    func testExtractCIDFromReserveAddress() throws {
        // First create a valid address
        let originalHash = Data(repeating: 123, count: 32)
        let originalCID = CID(version: .v0, codec: .dagPB, hash: originalHash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: originalCID)

        // Then extract it
        let extractedCID = try ARC19CID.extractCID(from: reserveAddress)

        XCTAssertEqual(extractedCID.version, .v0)
        XCTAssertEqual(extractedCID.codec, .dagPB)
        XCTAssertEqual(extractedCID.hash.count, 32)
    }

    func testEncodeCIDToReserveAddress() throws {
        // Create a CID with a known hash (all zeros for testing)
        let hash = Data(repeating: 0, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)

        let address = try ARC19CID.encodeToReserveAddress(cid: cid)

        XCTAssertEqual(address.count, 58) // Algorand addresses are 58 characters
    }

    func testRoundTripCIDEncoding() throws {
        let hash = Data(repeating: 42, count: 32)
        let originalCID = CID(version: .v0, codec: .dagPB, hash: hash)

        let address = try ARC19CID.encodeToReserveAddress(cid: originalCID)
        let extractedCID = try ARC19CID.extractCID(from: address)

        XCTAssertEqual(extractedCID.version, originalCID.version)
        XCTAssertEqual(extractedCID.codec, originalCID.codec)
        XCTAssertEqual(extractedCID.hash, originalCID.hash)
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONEncoding() throws {
        let hash = Data(repeating: 5, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let reserveAddress = try ARC19CID.encodeToReserveAddress(cid: cid)

        let template = try ARC19Template(
            templateUrl: "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}/metadata/{id}",
            reserveAddress: reserveAddress
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(template)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ARC19Template.self, from: data)

        XCTAssertEqual(decoded.templateUrl, template.templateUrl)
        XCTAssertEqual(decoded.reserveAddress, template.reserveAddress)
    }
}
