import Foundation

/// Fluent builder for ARC-69 metadata
public struct ARC69Builder: Sendable {
    private var standard: String
    private var description: String?
    private var externalUrl: String?
    private var mediaUrl: String?
    private var properties: [String: PropertyValue]?
    private var mimeType: String?

    public init() {
        self.standard = "arc69"
    }

    public func description(_ value: String) -> ARC69Builder {
        var copy = self
        copy.description = value
        return copy
    }

    public func externalUrl(_ url: String) -> ARC69Builder {
        var copy = self
        copy.externalUrl = url
        return copy
    }

    public func mediaUrl(_ url: String) -> ARC69Builder {
        var copy = self
        copy.mediaUrl = url
        return copy
    }

    /// Set media URL with a specific fragment
    public func mediaUrl(_ url: String, fragment: ARC69MediaFragment) -> ARC69Builder {
        var copy = self
        copy.mediaUrl = fragment.apply(to: url)
        return copy
    }

    /// Set media URL and infer fragment from MIME type
    public func media(url: String, mimeType: String) -> ARC69Builder {
        var copy = self
        copy.mimeType = mimeType

        if let fragment = ARC69MediaFragment.infer(from: mimeType) {
            copy.mediaUrl = fragment.apply(to: url)
        } else {
            copy.mediaUrl = url
        }

        return copy
    }

    public func mimeType(_ value: String) -> ARC69Builder {
        var copy = self
        copy.mimeType = value
        return copy
    }

    public func property(key: String, value: PropertyValue) -> ARC69Builder {
        var copy = self
        if copy.properties == nil {
            copy.properties = [:]
        }
        copy.properties?[key] = value
        return copy
    }

    public func properties(_ values: [String: PropertyValue]) -> ARC69Builder {
        var copy = self
        copy.properties = values
        return copy
    }

    /// Add image media with automatic fragment
    public func image(url: String, mimeType: String = "image/png") -> ARC69Builder {
        media(url: url, mimeType: mimeType)
    }

    /// Add video media with automatic fragment
    public func video(url: String, mimeType: String = "video/mp4") -> ARC69Builder {
        media(url: url, mimeType: mimeType)
    }

    /// Add audio media with automatic fragment
    public func audio(url: String, mimeType: String = "audio/mpeg") -> ARC69Builder {
        media(url: url, mimeType: mimeType)
    }

    /// Add PDF media with automatic fragment
    public func pdfDocument(url: String) -> ARC69Builder {
        media(url: url, mimeType: "application/pdf")
    }

    /// Add HTML media with automatic fragment
    public func htmlDocument(url: String) -> ARC69Builder {
        media(url: url, mimeType: "text/html")
    }

    public func build() -> ARC69Metadata {
        ARC69Metadata(
            standard: standard,
            description: description,
            externalUrl: externalUrl,
            mediaUrl: mediaUrl,
            properties: properties,
            mimeType: mimeType
        )
    }

    /// Validate and build, throwing if validation fails
    public func validated() throws -> ARC69Metadata {
        let metadata = build()
        let result = metadata.validate()

        guard result.isValid else {
            throw ARCError.validationFailed(result.failures)
        }

        return metadata
    }
}

extension ARC69Metadata {
    /// Create a builder from this metadata
    public func toBuilder() -> ARC69Builder {
        var builder = ARC69Builder()
            .description(description ?? "")
            .externalUrl(externalUrl ?? "")
            .mediaUrl(mediaUrl ?? "")
            .properties(properties ?? [:])

        if let mimeType {
            builder = builder.mimeType(mimeType)
        }

        return builder
    }
}
