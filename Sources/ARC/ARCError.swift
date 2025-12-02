import Foundation

/// Errors that can occur when working with ARC standards
public enum ARCError: Error, Sendable {
    case invalidMetadata(String)
    case invalidURL(String)
    case invalidCID(String)
    case invalidReserveAddress(String)
    case invalidPropertyValue(String)
    case validationFailed([ValidationFailure])
    case encodingFailed(String)
    case decodingFailed(String)
    case missingRequiredField(String)
    case invalidMediaFragment(String)
}

extension ARCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidMetadata(let message):
            return "Invalid metadata: \(message)"
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidCID(let message):
            return "Invalid CID: \(message)"
        case .invalidReserveAddress(let message):
            return "Invalid reserve address: \(message)"
        case .invalidPropertyValue(let message):
            return "Invalid property value: \(message)"
        case .validationFailed(let failures):
            return "Validation failed: \(failures.map(\.message).joined(separator: ", "))"
        case .encodingFailed(let message):
            return "Encoding failed: \(message)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidMediaFragment(let message):
            return "Invalid media fragment: \(message)"
        }
    }
}

/// Represents a validation failure with context
public struct ValidationFailure: Sendable, Equatable {
    public let field: String
    public let message: String
    public let severity: Severity

    public enum Severity: String, Sendable {
        case error
        case warning
    }

    public init(field: String, message: String, severity: Severity = .error) {
        self.field = field
        self.message = message
        self.severity = severity
    }
}
