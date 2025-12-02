import Foundation

/// Base protocol for all ARC metadata types
public protocol ARCMetadata: Sendable, Codable {
    /// Validate the metadata according to the ARC standard
    func validate() -> ValidationResult
}

/// Protocol for metadata with properties
public protocol PropertyMetadata: ARCMetadata {
    var properties: [String: PropertyValue]? { get }
}

/// Protocol for metadata with localization support
public protocol LocalizableMetadata: ARCMetadata {
    var localization: LocalizationInfo? { get }
}

/// Localization information for metadata
public struct LocalizationInfo: Sendable, Codable, Equatable {
    /// URI pointing to localized data
    public let uri: String

    /// Default locale (BCP 47 language tag)
    public let defaultLocale: String

    /// Available locales
    public let locales: [String]

    /// Integrity hash for the localization file
    public let integrity: String?

    public init(
        uri: String,
        defaultLocale: String,
        locales: [String],
        integrity: String? = nil
    ) {
        self.uri = uri
        self.defaultLocale = defaultLocale
        self.locales = locales
        self.integrity = integrity
    }

    enum CodingKeys: String, CodingKey {
        case uri
        case defaultLocale = "default"
        case locales
        case integrity
    }
}
