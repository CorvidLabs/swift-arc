import XCTest
@testable import ARC

final class ARC69Tests: XCTestCase {
    // MARK: - Metadata Creation Tests

    func testARC69MetadataCreation() {
        let metadata = ARC69Metadata(
            description: "A test NFT",
            mediaUrl: "https://example.com/image.png#i"
        )

        XCTAssertEqual(metadata.standard, "arc69")
        XCTAssertEqual(metadata.description, "A test NFT")
        XCTAssertEqual(metadata.mediaUrl, "https://example.com/image.png#i")
    }

    func testARC69MetadataWithProperties() {
        let metadata = ARC69Metadata(
            properties: [
                "rarity": "legendary",
                "level": 100
            ]
        )

        XCTAssertEqual(metadata.properties?["rarity"], .string("legendary"))
        XCTAssertEqual(metadata.properties?["level"], .number(100))
    }

    // MARK: - Validation Tests

    func testValidMetadata() {
        let metadata = ARC69Metadata(
            description: "Valid NFT",
            mediaUrl: "https://example.com/image.png#i",
            mimeType: "image/png"
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
    }

    func testInvalidStandard() {
        let metadata = ARC69Metadata(
            standard: "arc3",
            description: "Test"
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.failures.contains { $0.field == "standard" })
    }

    func testInvalidMediaURL() {
        let metadata = ARC69Metadata(
            mediaUrl: "not a valid url"
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.failures.contains { $0.field == "media_url" })
    }

    func testInvalidMimeType() {
        let metadata = ARC69Metadata(
            mimeType: "invalid-mime"
        )

        let result = metadata.validate()
        XCTAssertFalse(result.isValid)
    }

    func testFragmentMismatchWarning() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/video.mp4#i", // Image fragment
            mimeType: "video/mp4" // But video MIME type
        )

        let result = metadata.validate()
        XCTAssertTrue(result.isValid)
        XCTAssertFalse(result.warnings.isEmpty)
    }

    // MARK: - Media Fragment Tests

    func testMediaFragmentImage() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/image.png#i"
        )

        let fragment = metadata.mediaFragment
        XCTAssertEqual(fragment, .image)
    }

    func testMediaFragmentVideo() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/video.mp4#v"
        )

        let fragment = metadata.mediaFragment
        XCTAssertEqual(fragment, .video)
    }

    func testMediaFragmentAudio() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/audio.mp3#a"
        )

        let fragment = metadata.mediaFragment
        XCTAssertEqual(fragment, .audio)
    }

    func testMediaFragmentPDF() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/document.pdf#p"
        )

        let fragment = metadata.mediaFragment
        XCTAssertEqual(fragment, .pdf)
    }

    func testMediaFragmentHTML() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/page.html#h"
        )

        let fragment = metadata.mediaFragment
        XCTAssertEqual(fragment, .html)
    }

    func testNoMediaFragment() {
        let metadata = ARC69Metadata(
            mediaUrl: "https://example.com/file.png"
        )

        XCTAssertNil(metadata.mediaFragment)
    }

    // MARK: - Builder Tests

    func testBuilderBasic() {
        let metadata = ARC69Builder()
            .description("Test NFT")
            .externalUrl("https://example.com")
            .build()

        XCTAssertEqual(metadata.standard, "arc69")
        XCTAssertEqual(metadata.description, "Test NFT")
        XCTAssertEqual(metadata.externalUrl, "https://example.com")
    }

    func testBuilderWithMediaUrl() {
        let metadata = ARC69Builder()
            .mediaUrl("https://example.com/image.png")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/image.png")
    }

    func testBuilderWithMediaUrlAndFragment() {
        let metadata = ARC69Builder()
            .mediaUrl("https://example.com/image.png", fragment: .image)
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/image.png#i")
    }

    func testBuilderWithMedia() {
        let metadata = ARC69Builder()
            .media(url: "https://example.com/video.mp4", mimeType: "video/mp4")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/video.mp4#v")
        XCTAssertEqual(metadata.mimeType, "video/mp4")
    }

    func testBuilderImage() {
        let metadata = ARC69Builder()
            .image(url: "https://example.com/image.png")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/image.png#i")
        XCTAssertEqual(metadata.mimeType, "image/png")
    }

    func testBuilderVideo() {
        let metadata = ARC69Builder()
            .video(url: "https://example.com/video.mp4")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/video.mp4#v")
        XCTAssertEqual(metadata.mimeType, "video/mp4")
    }

    func testBuilderAudio() {
        let metadata = ARC69Builder()
            .audio(url: "https://example.com/audio.mp3")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/audio.mp3#a")
        XCTAssertEqual(metadata.mimeType, "audio/mpeg")
    }

    func testBuilderPDF() {
        let metadata = ARC69Builder()
            .pdfDocument(url: "https://example.com/doc.pdf")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/doc.pdf#p")
        XCTAssertEqual(metadata.mimeType, "application/pdf")
    }

    func testBuilderHTML() {
        let metadata = ARC69Builder()
            .htmlDocument(url: "https://example.com/page.html")
            .build()

        XCTAssertEqual(metadata.mediaUrl, "https://example.com/page.html#h")
        XCTAssertEqual(metadata.mimeType, "text/html")
    }

    func testBuilderWithProperties() {
        let metadata = ARC69Builder()
            .property(key: "rarity", value: "legendary")
            .property(key: "level", value: 100)
            .build()

        XCTAssertEqual(metadata.properties?["rarity"], .string("legendary"))
        XCTAssertEqual(metadata.properties?["level"], .number(100))
    }

    func testBuilderValidated() throws {
        let metadata = try ARC69Builder()
            .description("Valid NFT")
            .image(url: "https://example.com/image.png")
            .validated()

        XCTAssertEqual(metadata.description, "Valid NFT")
    }

    func testBuilderValidatedFailure() {
        XCTAssertThrowsError(
            try ARC69Builder()
                .mediaUrl("invalid url")
                .validated()
        )
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONEncoding() throws {
        let metadata = ARC69Metadata(
            description: "Test NFT",
            mediaUrl: "https://example.com/image.png#i"
        )

        let json = try metadata.toJSON()
        let decoded = try ARC69Metadata.from(json: json)

        XCTAssertEqual(decoded.standard, metadata.standard)
        XCTAssertEqual(decoded.description, metadata.description)
        XCTAssertEqual(decoded.mediaUrl, metadata.mediaUrl)
    }

    func testJSONString() throws {
        let metadata = ARC69Metadata(description: "Test")
        let jsonString = try metadata.toJSONString()

        XCTAssertTrue(jsonString.contains("\"standard\""))
        XCTAssertTrue(jsonString.contains("\"arc69\""))
    }

    func testCompactJSONString() throws {
        let metadata = ARC69Metadata(description: "Test")
        let compact = try metadata.toCompactJSONString()

        // Compact JSON should not have extra whitespace
        XCTAssertFalse(compact.contains("\n"))
        XCTAssertTrue(compact.contains("\"standard\":\"arc69\""))
    }

    func testFromJSONString() throws {
        let jsonString = """
        {
            "standard": "arc69",
            "description": "Test NFT",
            "media_url": "https://example.com/image.png#i"
        }
        """

        let metadata = try ARC69Metadata.from(jsonString: jsonString)

        XCTAssertEqual(metadata.standard, "arc69")
        XCTAssertEqual(metadata.description, "Test NFT")
        XCTAssertEqual(metadata.mediaUrl, "https://example.com/image.png#i")
    }

    // MARK: - Media Fragment Utility Tests

    func testFragmentExtraction() throws {
        let fragment = try ARC69MediaFragment.extract(from: "https://example.com/image.png#i")
        XCTAssertEqual(fragment, .image)
    }

    func testFragmentExtractionNoFragment() throws {
        let fragment = try ARC69MediaFragment.extract(from: "https://example.com/image.png")
        XCTAssertNil(fragment)
    }

    func testFragmentExtractionInvalid() {
        XCTAssertThrowsError(
            try ARC69MediaFragment.extract(from: "https://example.com/file#x")
        )
    }

    func testFragmentRemoval() {
        let url = "https://example.com/image.png#i"
        let cleaned = ARC69MediaFragment.removeFragment(from: url)
        XCTAssertEqual(cleaned, "https://example.com/image.png")
    }

    func testFragmentApply() {
        let url = "https://example.com/image.png"
        let withFragment = ARC69MediaFragment.image.apply(to: url)
        XCTAssertEqual(withFragment, "https://example.com/image.png#i")
    }

    func testFragmentApplyReplace() {
        let url = "https://example.com/image.png#v"
        let withFragment = ARC69MediaFragment.image.apply(to: url)
        XCTAssertEqual(withFragment, "https://example.com/image.png#i")
    }

    func testFragmentMatchesMimeType() {
        XCTAssertTrue(ARC69MediaFragment.image.matches(mimeType: "image/png"))
        XCTAssertTrue(ARC69MediaFragment.video.matches(mimeType: "video/mp4"))
        XCTAssertTrue(ARC69MediaFragment.audio.matches(mimeType: "audio/mpeg"))
        XCTAssertTrue(ARC69MediaFragment.pdf.matches(mimeType: "application/pdf"))
        XCTAssertTrue(ARC69MediaFragment.html.matches(mimeType: "text/html"))

        XCTAssertFalse(ARC69MediaFragment.image.matches(mimeType: "video/mp4"))
    }

    func testFragmentInferFromMimeType() {
        XCTAssertEqual(ARC69MediaFragment.infer(from: "image/png"), .image)
        XCTAssertEqual(ARC69MediaFragment.infer(from: "video/mp4"), .video)
        XCTAssertEqual(ARC69MediaFragment.infer(from: "audio/mpeg"), .audio)
        XCTAssertEqual(ARC69MediaFragment.infer(from: "application/pdf"), .pdf)
        XCTAssertEqual(ARC69MediaFragment.infer(from: "text/html"), .html)

        XCTAssertNil(ARC69MediaFragment.infer(from: "application/json"))
    }
}
