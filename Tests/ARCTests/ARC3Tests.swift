import XCTest
@testable import ARC

final class ARC3Tests: XCTestCase {
    // Helper to create a valid CID string for testing
    private var testCIDString: String {
        CID(version: .v0, codec: .dagPB, hash: Data(repeating: 42, count: 32)).toString()
    }

    // MARK: - Metadata Tests

    func testARC3MetadataCreation() {
        let imageUrl = "ipfs://\(testCIDString)"
        let metadata = ARC3Metadata(
            name: "Test NFT",
            description: "A test NFT",
            image: imageUrl
        )

        XCTAssertEqual(metadata.name, "Test NFT")
        XCTAssertEqual(metadata.description, "A test NFT")
        XCTAssertEqual(metadata.image, imageUrl)
    }

    func testARC3MetadataWithProperties() {
        let metadata = ARC3Metadata(
            name: "Test NFT",
            properties: [
                "rarity": "legendary",
                "level": 42,
                "stats": [
                    "strength": 100,
                    "agility": 75
                ]
            ]
        )

        XCTAssertEqual(metadata.properties?["rarity"], .string("legendary"))
        XCTAssertEqual(metadata.properties?["level"], .number(42))

        if case .object(let stats) = metadata.properties?["stats"] {
            XCTAssertEqual(stats["strength"], .number(100))
            XCTAssertEqual(stats["agility"], .number(75))
        } else {
            XCTFail("Expected object for stats")
        }
    }

    // MARK: - Validation Tests

    func testValidMetadata() {
        let metadata = ARC3Metadata(
            name: "Valid NFT",
            description: "A valid NFT",
            image: "ipfs://\(testCIDString)",
            imageMimeType: "image/png"
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.failures.isEmpty)
    }

    func testInvalidEmptyName() {
        let metadata = ARC3Metadata(name: "")

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.failures.contains { $0.field == "name" })
    }

    func testInvalidURL() {
        let metadata = ARC3Metadata(
            name: "Test",
            image: "://invalid" // Truly invalid URL
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.failures.contains { $0.field == "image" })
    }

    func testInvalidMimeType() {
        let metadata = ARC3Metadata(
            name: "Test",
            imageMimeType: "invalid-mime"
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.failures.contains { $0.field == "image_mimetype" })
    }

    func testValidIPFSURL() {
        let metadata = ARC3Metadata(
            name: "Test",
            image: "ipfs://\(testCIDString)/image.png"
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
    }

    func testValidIntegrity() {
        let metadata = ARC3Metadata(
            name: "Test",
            imageIntegrity: "sha256-abc123def456=="
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
    }

    func testInvalidIntegrity() {
        let metadata = ARC3Metadata(
            name: "Test",
            imageIntegrity: "invalid-integrity"
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
    }

    // MARK: - Builder Tests

    func testBuilderBasic() {
        let metadata = ARC3Builder(name: "Test NFT")
            .description("A test NFT")
            .image("ipfs://QmTest123")
            .build()

        XCTAssertEqual(metadata.name, "Test NFT")
        XCTAssertEqual(metadata.description, "A test NFT")
        XCTAssertEqual(metadata.image, "ipfs://QmTest123")
    }

    func testBuilderWithProperties() {
        let metadata = ARC3Builder(name: "Test")
            .property(key: "color", value: "red")
            .property(key: "size", value: 42)
            .build()

        XCTAssertEqual(metadata.properties?["color"], .string("red"))
        XCTAssertEqual(metadata.properties?["size"], .number(42))
    }

    func testBuilderWithMultipleProperties() {
        let metadata = ARC3Builder(name: "Test")
            .properties([
                "rarity": "legendary",
                "level": 100
            ])
            .build()

        XCTAssertEqual(metadata.properties?["rarity"], .string("legendary"))
        XCTAssertEqual(metadata.properties?["level"], .number(100))
    }

    func testBuilderWithExtra() {
        let metadata = ARC3Builder(name: "Test")
            .extra(key: "custom", value: "data")
            .build()

        XCTAssertEqual(metadata.extra?["custom"], .string("data"))
    }

    func testBuilderWithAllFields() {
        let localization = LocalizationInfo(
            uri: "ipfs://QmLocalization",
            defaultLocale: "en",
            locales: ["en", "es", "fr"]
        )

        let metadata = ARC3Builder(name: "Complete NFT")
            .description("A complete NFT")
            .image("ipfs://QmImage", integrity: "sha256-abc==", mimeType: "image/png")
            .externalUrl("https://example.com", integrity: "sha256-def==", mimeType: "text/html")
            .animationUrl("ipfs://QmAnim", integrity: "sha256-ghi==", mimeType: "video/mp4")
            .property(key: "rarity", value: "legendary")
            .extra(key: "custom", value: "data")
            .localization(localization)
            .build()

        XCTAssertEqual(metadata.name, "Complete NFT")
        XCTAssertEqual(metadata.description, "A complete NFT")
        XCTAssertEqual(metadata.image, "ipfs://QmImage")
        XCTAssertEqual(metadata.imageIntegrity, "sha256-abc==")
        XCTAssertEqual(metadata.imageMimeType, "image/png")
        XCTAssertNotNil(metadata.localization)
    }

    func testBuilderValidated() throws {
        let metadata = try ARC3Builder(name: "Valid NFT")
            .description("A valid NFT")
            .validated()

        XCTAssertEqual(metadata.name, "Valid NFT")
    }

    func testBuilderValidatedFailure() {
        XCTAssertThrowsError(try ARC3Builder(name: "")
            .validated()
        )
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONEncoding() throws {
        let metadata = ARC3Metadata(
            name: "Test NFT",
            description: "A test NFT",
            image: "ipfs://QmTest123"
        )

        let json = try metadata.toJSON()
        XCTAssertFalse(json.isEmpty)

        let decoded = try ARC3Metadata.from(json: json)
        XCTAssertEqual(decoded.name, metadata.name)
        XCTAssertEqual(decoded.description, metadata.description)
        XCTAssertEqual(decoded.image, metadata.image)
    }

    func testJSONEncodingWithProperties() throws {
        let metadata = ARC3Metadata(
            name: "Test",
            properties: [
                "string": "value",
                "number": 42,
                "nested": ["key": "value"]
            ]
        )

        let json = try metadata.toJSON()
        let decoded = try ARC3Metadata.from(json: json)

        XCTAssertEqual(decoded.properties?["string"], .string("value"))
        XCTAssertEqual(decoded.properties?["number"], .number(42))

        if case .object(let nested) = decoded.properties?["nested"] {
            XCTAssertEqual(nested["key"], .string("value"))
        } else {
            XCTFail("Expected nested object")
        }
    }

    func testJSONString() throws {
        let metadata = ARC3Metadata(name: "Test")
        let jsonString = try metadata.toJSONString()

        XCTAssertTrue(jsonString.contains("\"name\""))
        XCTAssertTrue(jsonString.contains("\"Test\""))
    }

    // MARK: - Localization Tests

    func testLocalization() {
        let localization = LocalizationInfo(
            uri: "ipfs://QmLocalization",
            defaultLocale: "en",
            locales: ["en", "es", "fr"],
            integrity: "sha256-abc=="
        )

        let metadata = ARC3Metadata(
            name: "Test",
            localization: localization
        )

        XCTAssertEqual(metadata.localization?.uri, "ipfs://QmLocalization")
        XCTAssertEqual(metadata.localization?.defaultLocale, "en")
        XCTAssertEqual(metadata.localization?.locales, ["en", "es", "fr"])
    }

    func testLocalizationValidation() {
        let localization = LocalizationInfo(
            uri: "ipfs://QmLocalization",
            defaultLocale: "en",
            locales: ["en", "es"]
        )

        let metadata = ARC3Metadata(
            name: "Test",
            localization: localization
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
    }

    func testLocalizationValidationMissingDefault() {
        let localization = LocalizationInfo(
            uri: "ipfs://QmLocalization",
            defaultLocale: "en",
            locales: ["es", "fr"]
        )

        let metadata = ARC3Metadata(
            name: "Test",
            localization: localization
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid) // Should be valid but with warning
        XCTAssertFalse(result.warnings.isEmpty)
    }
}
