import Foundation

/// Validator for ARC-69 metadata
public struct ARC69Validator: ARCValidator {
    public typealias Metadata = ARC69Metadata

    private let base = BaseValidator()

    public init() {}

    public func validate(_ metadata: ARC69Metadata) -> ValidationResult {
        var results: [ValidationResult] = []

        // Standard must be "arc69"
        if metadata.standard != "arc69" {
            results.append(.failure(
                field: "standard",
                message: "Standard must be 'arc69', got '\(metadata.standard)'"
            ))
        }

        // Validate URLs if present
        if let externalUrl = metadata.externalUrl, !externalUrl.isEmpty {
            results.append(base.validateURL(externalUrl, field: "external_url"))
        }

        if let mediaUrl = metadata.mediaUrl, !mediaUrl.isEmpty {
            results.append(validateMediaUrl(mediaUrl))
        }

        // Validate MIME type if present
        if let mimeType = metadata.mimeType {
            results.append(base.validateMediaType(mimeType, field: "mime_type"))

            // If both media URL and MIME type are present, validate fragment consistency
            if let mediaUrl = metadata.mediaUrl,
               let fragment = try? ARC69MediaFragment.extract(from: mediaUrl) {
                if !fragment.matches(mimeType: mimeType) {
                    results.append(.warning(
                        field: "media_url",
                        message: "Media fragment '\(fragment.identifier)' does not match MIME type '\(mimeType)'"
                    ))
                }
            }
        }

        // Validate that at least one content field is present
        let hasContent = metadata.description != nil ||
                        metadata.externalUrl != nil ||
                        metadata.mediaUrl != nil ||
                        metadata.properties != nil

        if !hasContent {
            results.append(.warning(
                field: "metadata",
                message: "Metadata should contain at least one of: description, external_url, media_url, or properties"
            ))
        }

        return ValidationResult.combine(results)
    }

    private func validateMediaUrl(_ mediaUrl: String) -> ValidationResult {
        var results: [ValidationResult] = []

        // Validate base URL
        let baseUrl = ARC69MediaFragment.removeFragment(from: mediaUrl)
        results.append(base.validateURL(baseUrl, field: "media_url"))

        // Validate fragment if present
        if mediaUrl.contains("#") {
            do {
                _ = try ARC69MediaFragment.extract(from: mediaUrl)
            } catch {
                results.append(.failure(
                    field: "media_url",
                    message: "Invalid media fragment: \(error.localizedDescription)"
                ))
            }
        }

        return ValidationResult.combine(results)
    }
}
