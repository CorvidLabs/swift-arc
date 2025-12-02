import Foundation

/// Validator for ARC-3 metadata
public struct ARC3Validator: ARCValidator {
    public typealias Metadata = ARC3Metadata

    private let base = BaseValidator()

    public init() {}

    public func validate(_ metadata: ARC3Metadata) -> ValidationResult {
        var results: [ValidationResult] = []

        // Name is required
        results.append(base.validateNotEmpty(metadata.name, field: "name"))

        // Validate URLs if present
        if let image = metadata.image {
            results.append(validateURL(image, field: "image"))
        }

        if let externalUrl = metadata.externalUrl {
            results.append(validateURL(externalUrl, field: "external_url"))
        }

        if let animationUrl = metadata.animationUrl {
            results.append(validateURL(animationUrl, field: "animation_url"))
        }

        // Validate MIME types if present
        if let imageMimeType = metadata.imageMimeType {
            results.append(base.validateMediaType(imageMimeType, field: "image_mimetype"))
        }

        if let externalUrlMimeType = metadata.externalUrlMimeType {
            results.append(base.validateMediaType(externalUrlMimeType, field: "external_url_mimetype"))
        }

        if let animationUrlMimeType = metadata.animationUrlMimeType {
            results.append(base.validateMediaType(animationUrlMimeType, field: "animation_url_mimetype"))
        }

        // Validate integrity values if present
        if let imageIntegrity = metadata.imageIntegrity {
            results.append(validateIntegrity(imageIntegrity, field: "image_integrity"))
        }

        if let externalUrlIntegrity = metadata.externalUrlIntegrity {
            results.append(validateIntegrity(externalUrlIntegrity, field: "external_url_integrity"))
        }

        if let animationUrlIntegrity = metadata.animationUrlIntegrity {
            results.append(validateIntegrity(animationUrlIntegrity, field: "animation_url_integrity"))
        }

        // Validate localization if present
        if let localization = metadata.localization {
            results.append(validateLocalization(localization))
        }

        return ValidationResult.combine(results)
    }

    private func validateURL(_ urlString: String, field: String) -> ValidationResult {
        // Check if it's an IPFS URL
        if urlString.hasPrefix("ipfs://") || urlString.hasPrefix("template-ipfs://") {
            do {
                _ = try IPFSUrl(string: urlString)
                return .valid
            } catch {
                return .failure(field: field, message: "Invalid IPFS URL: \(error.localizedDescription)")
            }
        }

        // Otherwise validate as regular URL
        return base.validateURL(urlString, field: field)
    }

    private func validateIntegrity(_ integrity: String, field: String) -> ValidationResult {
        // Integrity should be in format: sha256-{base64}
        let pattern = #"^(sha256|sha384|sha512)-[A-Za-z0-9+/]+=*$"#
        return base.validatePattern(
            integrity,
            pattern: pattern,
            field: field,
            message: "Integrity must be in format: algorithm-base64hash"
        )
    }

    private func validateLocalization(_ localization: LocalizationInfo) -> ValidationResult {
        var results: [ValidationResult] = []

        // URI is required
        results.append(base.validateNotEmpty(localization.uri, field: "localization.uri"))

        // Default locale is required
        results.append(base.validateNotEmpty(localization.defaultLocale, field: "localization.default"))

        // Locales array should not be empty
        if localization.locales.isEmpty {
            results.append(.failure(field: "localization.locales", message: "Locales array cannot be empty"))
        }

        // Default locale should be in the locales array
        if !localization.locales.contains(localization.defaultLocale) {
            results.append(.warning(
                field: "localization.default",
                message: "Default locale '\(localization.defaultLocale)' not found in locales array"
            ))
        }

        return ValidationResult.combine(results)
    }
}
