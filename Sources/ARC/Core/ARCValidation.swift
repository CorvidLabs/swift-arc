import Foundation

/// Result of validating ARC metadata
public struct ValidationResult: Sendable, Equatable {
    public let isValid: Bool
    public let failures: [ValidationFailure]
    public let warnings: [ValidationFailure]

    public static let valid = ValidationResult(isValid: true, failures: [], warnings: [])

    public init(isValid: Bool, failures: [ValidationFailure], warnings: [ValidationFailure] = []) {
        self.isValid = isValid
        self.failures = failures
        self.warnings = warnings
    }

    public static func invalid(_ failures: [ValidationFailure]) -> ValidationResult {
        ValidationResult(
            isValid: false,
            failures: failures.filter { $0.severity == .error },
            warnings: failures.filter { $0.severity == .warning }
        )
    }

    public static func failure(field: String, message: String) -> ValidationResult {
        .invalid([ValidationFailure(field: field, message: message)])
    }

    public static func warning(field: String, message: String) -> ValidationResult {
        ValidationResult(
            isValid: true,
            failures: [],
            warnings: [ValidationFailure(field: field, message: message, severity: .warning)]
        )
    }

    /// Combine multiple validation results
    public static func combine(_ results: [ValidationResult]) -> ValidationResult {
        let allFailures = results.flatMap(\.failures)
        let allWarnings = results.flatMap(\.warnings)
        let isValid = results.allSatisfy(\.isValid)

        return ValidationResult(
            isValid: isValid,
            failures: allFailures,
            warnings: allWarnings
        )
    }

    /// Combine this result with another
    public func combined(with other: ValidationResult) -> ValidationResult {
        ValidationResult(
            isValid: isValid && other.isValid,
            failures: failures + other.failures,
            warnings: warnings + other.warnings
        )
    }
}

/// Protocol for types that can validate ARC metadata
public protocol ARCValidator: Sendable {
    associatedtype Metadata: ARCMetadata

    /// Validate the given metadata
    func validate(_ metadata: Metadata) -> ValidationResult
}

/// Base validator with common validation utilities
public struct BaseValidator: Sendable {
    public init() {}

    /// Validate that a URL is properly formatted
    public func validateURL(_ urlString: String, field: String) -> ValidationResult {
        // Check for empty or whitespace-only strings
        guard !urlString.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(field: field, message: "URL cannot be empty")
        }

        // Try to parse as URL
        guard let url = URL(string: urlString) else {
            return .failure(field: field, message: "Invalid URL format")
        }

        // Ensure URL has a valid scheme
        guard url.scheme != nil && !url.scheme!.isEmpty else {
            return .failure(field: field, message: "URL must have a valid scheme")
        }

        return .valid
    }

    /// Validate that a string is not empty
    public func validateNotEmpty(_ value: String?, field: String) -> ValidationResult {
        guard let value, !value.isEmpty else {
            return .failure(field: field, message: "Field is required and cannot be empty")
        }
        return .valid
    }

    /// Validate that a value is present
    public func validatePresent<T>(_ value: T?, field: String) -> ValidationResult {
        guard value != nil else {
            return .failure(field: field, message: "Field is required")
        }
        return .valid
    }

    /// Validate that a string matches a pattern
    public func validatePattern(
        _ value: String,
        pattern: String,
        field: String,
        message: String
    ) -> ValidationResult {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(
                  in: value,
                  range: NSRange(value.startIndex..., in: value)
              ) != nil else {
            return .failure(field: field, message: message)
        }
        return .valid
    }

    /// Validate IPFS URL format
    public func validateIPFSURL(_ urlString: String, field: String) -> ValidationResult {
        guard urlString.hasPrefix("ipfs://") || urlString.hasPrefix("template-ipfs://") else {
            return .failure(field: field, message: "URL must use ipfs:// or template-ipfs:// scheme")
        }
        return .valid
    }

    /// Validate media type (MIME type)
    public func validateMediaType(_ mediaType: String, field: String) -> ValidationResult {
        let pattern = #"^[a-z]+/[a-z0-9\-\+\.]+$"#
        return validatePattern(
            mediaType.lowercased(),
            pattern: pattern,
            field: field,
            message: "Invalid media type format"
        )
    }
}
