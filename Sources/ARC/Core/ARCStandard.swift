import Foundation

/// Protocol representing an ARC standard
public protocol ARCStandard: Sendable {
    associatedtype Metadata: ARCMetadata

    /// The ARC standard number (e.g., 3, 19, 69)
    static var standardNumber: Int { get }

    /// The standard name
    static var standardName: String { get }

    /// Validate metadata against this standard
    static func validate(_ metadata: Metadata) -> ValidationResult
}

/// ARC-3: Algorand Standard Asset Parameters Conventions for Fungible and Non-Fungible Tokens
public enum ARC3: ARCStandard {
    public typealias Metadata = ARC3Metadata

    public static let standardNumber = 3
    public static let standardName = "ARC-3"

    public static func validate(_ metadata: ARC3Metadata) -> ValidationResult {
        ARC3Validator().validate(metadata)
    }
}

/// ARC-19: Templated URI for NFT Metadata
public enum ARC19: ARCStandard {
    public typealias Metadata = ARC19Template

    public static let standardNumber = 19
    public static let standardName = "ARC-19"

    public static func validate(_ metadata: ARC19Template) -> ValidationResult {
        metadata.validate()
    }
}

/// ARC-69: Algorand Standard for On-Chain NFT Metadata
public enum ARC69: ARCStandard {
    public typealias Metadata = ARC69Metadata

    public static let standardNumber = 69
    public static let standardName = "ARC-69"

    public static func validate(_ metadata: ARC69Metadata) -> ValidationResult {
        ARC69Validator().validate(metadata)
    }
}
