import Foundation

/// Fluent builder for ARC-3 metadata
public struct ARC3Builder: Sendable {
    private var name: String
    private var description: String?
    private var image: String?
    private var imageIntegrity: String?
    private var imageMimeType: String?
    private var externalUrl: String?
    private var externalUrlIntegrity: String?
    private var externalUrlMimeType: String?
    private var animationUrl: String?
    private var animationUrlIntegrity: String?
    private var animationUrlMimeType: String?
    private var properties: [String: PropertyValue]?
    private var extra: [String: PropertyValue]?
    private var localization: LocalizationInfo?

    public init(name: String) {
        self.name = name
    }

    public func name(_ value: String) -> ARC3Builder {
        var copy = self
        copy.name = value
        return copy
    }

    public func description(_ value: String) -> ARC3Builder {
        var copy = self
        copy.description = value
        return copy
    }

    public func image(_ url: String, integrity: String? = nil, mimeType: String? = nil) -> ARC3Builder {
        var copy = self
        copy.image = url
        copy.imageIntegrity = integrity
        copy.imageMimeType = mimeType
        return copy
    }

    public func externalUrl(_ url: String, integrity: String? = nil, mimeType: String? = nil) -> ARC3Builder {
        var copy = self
        copy.externalUrl = url
        copy.externalUrlIntegrity = integrity
        copy.externalUrlMimeType = mimeType
        return copy
    }

    public func animationUrl(_ url: String, integrity: String? = nil, mimeType: String? = nil) -> ARC3Builder {
        var copy = self
        copy.animationUrl = url
        copy.animationUrlIntegrity = integrity
        copy.animationUrlMimeType = mimeType
        return copy
    }

    public func property(key: String, value: PropertyValue) -> ARC3Builder {
        var copy = self
        if copy.properties == nil {
            copy.properties = [:]
        }
        copy.properties?[key] = value
        return copy
    }

    public func properties(_ values: [String: PropertyValue]) -> ARC3Builder {
        var copy = self
        copy.properties = values
        return copy
    }

    public func extra(key: String, value: PropertyValue) -> ARC3Builder {
        var copy = self
        if copy.extra == nil {
            copy.extra = [:]
        }
        copy.extra?[key] = value
        return copy
    }

    public func extra(_ values: [String: PropertyValue]) -> ARC3Builder {
        var copy = self
        copy.extra = values
        return copy
    }

    public func localization(_ info: LocalizationInfo) -> ARC3Builder {
        var copy = self
        copy.localization = info
        return copy
    }

    public func build() -> ARC3Metadata {
        ARC3Metadata(
            name: name,
            description: description,
            image: image,
            imageIntegrity: imageIntegrity,
            imageMimeType: imageMimeType,
            externalUrl: externalUrl,
            externalUrlIntegrity: externalUrlIntegrity,
            externalUrlMimeType: externalUrlMimeType,
            animationUrl: animationUrl,
            animationUrlIntegrity: animationUrlIntegrity,
            animationUrlMimeType: animationUrlMimeType,
            properties: properties,
            extra: extra,
            localization: localization
        )
    }

    /// Validate and build, throwing if validation fails
    public func validated() throws -> ARC3Metadata {
        let metadata = build()
        let result = metadata.validate()

        guard result.isValid else {
            throw ARCError.validationFailed(result.failures)
        }

        return metadata
    }
}

extension ARC3Metadata {
    /// Create a builder for this metadata
    public func toBuilder() -> ARC3Builder {
        ARC3Builder(name: name)
            .description(description ?? "")
            .image(image ?? "", integrity: imageIntegrity, mimeType: imageMimeType)
            .externalUrl(externalUrl ?? "", integrity: externalUrlIntegrity, mimeType: externalUrlMimeType)
            .animationUrl(animationUrl ?? "", integrity: animationUrlIntegrity, mimeType: animationUrlMimeType)
            .properties(properties ?? [:])
            .extra(extra ?? [:])
    }
}
