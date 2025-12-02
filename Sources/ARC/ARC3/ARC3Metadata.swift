import Foundation

/// ARC-3: Algorand Standard Asset Parameters Conventions for Fungible and Non-Fungible Tokens
public struct ARC3Metadata: ARCMetadata, PropertyMetadata, LocalizableMetadata, Equatable {
    /// Name of the asset
    public let name: String

    /// Description of the asset
    public let description: String?

    /// URL to the asset image
    public let image: String?

    /// MIME type of the image
    public let imageIntegrity: String?

    /// MIME type of the image
    public let imageMimeType: String?

    /// URL to external asset resource
    public let externalUrl: String?

    /// URL to external asset resource (alt)
    public let externalUrlIntegrity: String?

    /// MIME type of the external URL
    public let externalUrlMimeType: String?

    /// URL to animation
    public let animationUrl: String?

    /// Integrity hash for animation
    public let animationUrlIntegrity: String?

    /// MIME type of the animation
    public let animationUrlMimeType: String?

    /// Additional properties
    public let properties: [String: PropertyValue]?

    /// Extra metadata
    public let extra: [String: PropertyValue]?

    /// Localization information
    public let localization: LocalizationInfo?

    public init(
        name: String,
        description: String? = nil,
        image: String? = nil,
        imageIntegrity: String? = nil,
        imageMimeType: String? = nil,
        externalUrl: String? = nil,
        externalUrlIntegrity: String? = nil,
        externalUrlMimeType: String? = nil,
        animationUrl: String? = nil,
        animationUrlIntegrity: String? = nil,
        animationUrlMimeType: String? = nil,
        properties: [String: PropertyValue]? = nil,
        extra: [String: PropertyValue]? = nil,
        localization: LocalizationInfo? = nil
    ) {
        self.name = name
        self.description = description
        self.image = image
        self.imageIntegrity = imageIntegrity
        self.imageMimeType = imageMimeType
        self.externalUrl = externalUrl
        self.externalUrlIntegrity = externalUrlIntegrity
        self.externalUrlMimeType = externalUrlMimeType
        self.animationUrl = animationUrl
        self.animationUrlIntegrity = animationUrlIntegrity
        self.animationUrlMimeType = animationUrlMimeType
        self.properties = properties
        self.extra = extra
        self.localization = localization
    }

    public func validate() -> ValidationResult {
        ARC3Validator().validate(self)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case image
        case imageIntegrity = "image_integrity"
        case imageMimeType = "image_mimetype"
        case externalUrl = "external_url"
        case externalUrlIntegrity = "external_url_integrity"
        case externalUrlMimeType = "external_url_mimetype"
        case animationUrl = "animation_url"
        case animationUrlIntegrity = "animation_url_integrity"
        case animationUrlMimeType = "animation_url_mimetype"
        case properties
        case extra
        case localization
    }
}

extension ARC3Metadata {
    /// Create metadata from JSON data
    public static func from(json: Data) throws -> ARC3Metadata {
        let decoder = JSONDecoder()
        return try decoder.decode(ARC3Metadata.self, from: json)
    }

    /// Encode metadata to JSON data
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// Encode metadata to JSON string
    public func toJSONString() throws -> String {
        let data = try toJSON()
        guard let string = String(data: data, encoding: .utf8) else {
            throw ARCError.encodingFailed("Failed to convert JSON to string")
        }
        return string
    }
}
