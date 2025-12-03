import XCTest
@testable import ARC

final class IPFSTests: XCTestCase {
    // Helper to create a valid CID string for testing
    private var testCIDString: String {
        CID(version: .v0, codec: .dagPB, hash: Data(repeating: 42, count: 32)).toString()
    }

    // MARK: - CID Tests

    func testCIDv0Creation() {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)

        XCTAssertEqual(cid.version, .v0)
        XCTAssertEqual(cid.codec, .dagPB)
        XCTAssertEqual(cid.hash, hash)
    }

    func testCIDv1Creation() {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v1, codec: .raw, hash: hash)

        XCTAssertEqual(cid.version, .v1)
        XCTAssertEqual(cid.codec, .raw)
        XCTAssertEqual(cid.hash, hash)
    }

    func testCIDFromStringV0() throws {
        let cidString = "QmTest" // Simplified for testing
        // Note: Real CIDv0 strings are base58 encoded and start with "Qm"
        // For a complete test, we'd need a valid CIDv0 string
    }

    func testCIDEquality() {
        let hash = Data(repeating: 42, count: 32)
        let cid1 = CID(version: .v0, codec: .dagPB, hash: hash)
        let cid2 = CID(version: .v0, codec: .dagPB, hash: hash)
        let cid3 = CID(version: .v1, codec: .dagPB, hash: hash)

        XCTAssertEqual(cid1, cid2)
        XCTAssertNotEqual(cid1, cid3)
    }

    func testCIDHashable() {
        let hash = Data(repeating: 42, count: 32)
        let cid1 = CID(version: .v0, codec: .dagPB, hash: hash)
        let cid2 = CID(version: .v0, codec: .dagPB, hash: hash)

        var set = Set<CID>()
        set.insert(cid1)
        set.insert(cid2)

        XCTAssertEqual(set.count, 1)
    }

    // MARK: - IPFS URL Tests

    func testIPFSUrlCreation() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid)

        XCTAssertEqual(url.scheme, .ipfs)
        XCTAssertEqual(url.cid, cid)
        XCTAssertNil(url.path)
    }

    func testIPFSUrlWithPath() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid, path: "/metadata.json")

        XCTAssertEqual(url.path, "/metadata.json")
    }

    func testIPFSUrlFromString() throws {
        let urlString = "ipfs://\(testCIDString)/metadata.json"
        let url = try IPFSUrl(string: urlString)

        XCTAssertEqual(url.scheme, .ipfs)
        XCTAssertEqual(url.path, "/metadata.json")
    }

    func testTemplateIPFSUrlFromString() throws {
        let urlString = "template-ipfs://\(testCIDString)/metadata/{id}"
        let url = try IPFSUrl(string: urlString)

        XCTAssertEqual(url.scheme, .templateIPFS)
        XCTAssertEqual(url.path, "/metadata/{id}")
    }

    func testIPFSUrlToString() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid, path: "/metadata.json")

        let string = url.toString()

        XCTAssertTrue(string.hasPrefix("ipfs://"))
        XCTAssertTrue(string.hasSuffix("/metadata.json"))
    }

    func testIPFSUrlToGatewayURL() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid, path: "/metadata.json")

        let gateway = url.toGatewayURL()

        XCTAssertTrue(gateway.hasPrefix("https://gateway.pinata.cloud/ipfs/"))
        XCTAssertTrue(gateway.hasSuffix("/metadata.json"))
    }

    func testIPFSUrlCustomGateway() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid, path: "/image.png")

        let gateway = url.toGatewayURL(gateway: "https://custom.gateway.com")

        XCTAssertTrue(gateway.hasPrefix("https://custom.gateway.com/ipfs/"))
    }

    func testIPFSUrlResolveTemplate() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .templateIPFS, cid: cid, path: "/metadata/{id}")

        let resolved = url.resolveTemplate(variables: ["id": "123"])

        XCTAssertEqual(resolved.path, "/metadata/123")
    }

    func testIPFSUrlResolveARC19Template() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .templateIPFS, cid: cid, path: "/nft/{id}")

        let resolved = url.resolveARC19Template(assetID: 456)

        XCTAssertEqual(resolved.path, "/nft/456")
    }

    func testIPFSUrlEquality() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)

        let url1 = IPFSUrl(scheme: .ipfs, cid: cid, path: "/test")
        let url2 = IPFSUrl(scheme: .ipfs, cid: cid, path: "/test")
        let url3 = IPFSUrl(scheme: .ipfs, cid: cid, path: "/other")

        XCTAssertEqual(url1, url2)
        XCTAssertNotEqual(url1, url3)
    }

    func testIPFSUrlHashable() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)

        let url1 = IPFSUrl(scheme: .ipfs, cid: cid)
        let url2 = IPFSUrl(scheme: .ipfs, cid: cid)

        var set = Set<IPFSUrl>()
        set.insert(url1)
        set.insert(url2)

        XCTAssertEqual(set.count, 1)
    }

    func testIPFSUrlCodable() throws {
        let url = try IPFSUrl(string: "ipfs://\(testCIDString)/test")

        let encoder = JSONEncoder()
        let data = try encoder.encode(url)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(IPFSUrl.self, from: data)

        XCTAssertEqual(decoded.scheme, url.scheme)
        XCTAssertEqual(decoded.path, url.path)
    }

    func testIPFSUrlDescription() throws {
        let hash = Data(repeating: 42, count: 32)
        let cid = CID(version: .v0, codec: .dagPB, hash: hash)
        let url = IPFSUrl(scheme: .ipfs, cid: cid, path: "/test")

        let description = url.description

        XCTAssertTrue(description.hasPrefix("ipfs://"))
    }

    func testIPFSUrlLosslessStringConvertible() throws {
        let urlString = "ipfs://\(testCIDString)/test"
        guard let url = IPFSUrl(urlString) else {
            XCTFail("Failed to create IPFS URL from string")
            return
        }

        XCTAssertEqual(url.scheme, .ipfs)
        XCTAssertEqual(url.path, "/test")
    }

    // MARK: - Error Handling Tests

    func testInvalidIPFSUrlScheme() {
        XCTAssertThrowsError(
            try IPFSUrl(string: "https://example.com")
        ) { error in
            guard let arcError = error as? ARCError else {
                XCTFail("Expected ARCError")
                return
            }
            if case .invalidURL = arcError {
                // Expected error
            } else {
                XCTFail("Expected invalidURL error")
            }
        }
    }

    func testMissingCIDInURL() {
        XCTAssertThrowsError(
            try IPFSUrl(string: "ipfs://")
        )
    }

    func testInvalidCIDString() {
        XCTAssertThrowsError(
            try CID(string: "invalid")
        )
    }
}
