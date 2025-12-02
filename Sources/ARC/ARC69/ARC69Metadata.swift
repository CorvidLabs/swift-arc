import Foundation

/// ARC-69: Algorand Standard for On-Chain NFT Metadata
public struct ARC69Metadata: ARCMetadata, PropertyMetadata, Equatable {
    /// Standard identifier (must be "arc69")
    public let standard: String

    /// Description of the asset
    public let description: String?

    /// External URL
    public let externalUrl: String?

    /// Media URL (can include fragments: #i, #v, #a, #p, #h)
    public let mediaUrl: String?

    /// Additional properties
    public let properties: [String: PropertyValue]?

    /// MIME type of the media
    public let mimeType: String?

    /// Parsed media fragment if present
    public var mediaFragment: ARC69MediaFragment? {
        guard let mediaUrl else { return nil }
        return try? ARC69MediaFragment.extract(from: mediaUrl)
    }

    public init(
        standard: String = "arc69",
        description: String? = nil,
        externalUrl: String? = nil,
        mediaUrl: String? = nil,
        properties: [String: PropertyValue]? = nil,
        mimeType: String? = nil
    ) {
        self.standard = standard
        self.description = description
        self.externalUrl = externalUrl
        self.mediaUrl = mediaUrl
        self.properties = properties
        self.mimeType = mimeType
    }

    public func validate() -> ValidationResult {
        ARC69Validator().validate(self)
    }

    enum CodingKeys: String, CodingKey {
        case standard
        case description
        case externalUrl = "external_url"
        case mediaUrl = "media_url"
        case properties
        case mimeType = "mime_type"
    }
}

extension ARC69Metadata {
    /// Create metadata from JSON data
    public static func from(json: Data) throws -> ARC69Metadata {
        let decoder = JSONDecoder()
        return try decoder.decode(ARC69Metadata.self, from: json)
    }

    /// Create metadata from JSON string
    public static func from(jsonString: String) throws -> ARC69Metadata {
        guard let data = jsonString.data(using: .utf8) else {
            throw ARCError.decodingFailed("Invalid UTF-8 string")
        }
        return try from(json: data)
    }

    /// Encode metadata to JSON data
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    /// Encode metadata to JSON string (for on-chain note field)
    public func toJSONString() throws -> String {
        let data = try toJSON()
        guard let string = String(data: data, encoding: .utf8) else {
            throw ARCError.encodingFailed("Failed to convert JSON to string")
        }
        return string
    }

    /// Convert to compact JSON string for on-chain storage
    /// Removes whitespace to minimize transaction size
    public func toCompactJSONString() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = []
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw ARCError.encodingFailed("Failed to convert JSON to string")
        }
        return string
    }
}
