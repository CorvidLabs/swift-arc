import Foundation

/// ARC-19: Templated URI for NFT Metadata
public struct ARC19Template: ARCMetadata, Equatable {
    /// The template URL (e.g., template-ipfs://{ipfscid:1:raw:reserve:sha2-256})
    public let templateUrl: String

    /// The reserve address containing the CID
    public let reserveAddress: String

    /// The parsed IPFS CID from the reserve address
    public let cid: CID

    /// The parsed template parameters
    public let templateParams: ARC19CID.TemplateParams

    public init(templateUrl: String, reserveAddress: String) throws {
        self.templateUrl = templateUrl
        self.reserveAddress = reserveAddress

        // Validate template URL format
        guard templateUrl.hasPrefix("template-ipfs://") else {
            throw ARCError.invalidURL("ARC-19 template must use template-ipfs:// scheme")
        }

        // Extract template parameters and CID from reserve address
        self.templateParams = try ARC19CID.parseTemplateParams(from: Self.extractPlaceholder(from: templateUrl))
        self.cid = try ARC19CID.extractCID(from: reserveAddress, params: templateParams, validateChecksum: false)
    }

    /// Create from a standard IPFS URL and reserve address
    public init(
        ipfsUrl: IPFSUrl,
        reserveAddress: String,
        pathTemplate: String = "/{id}",
        cidVersion: CID.Version = .v0,
        codec: CID.Codec = .dagPB
    ) throws {
        let templateUrl = "template-ipfs://{ipfscid:\(cidVersion.rawValue):\(codec.templateString):reserve:sha2-256}\(pathTemplate)"
        try self.init(templateUrl: templateUrl, reserveAddress: reserveAddress)
    }

    /// Extract the placeholder from a template URL
    private static func extractPlaceholder(from templateUrl: String) throws -> String {
        guard let startRange = templateUrl.range(of: "{ipfscid:"),
              let endRange = templateUrl.range(of: "}", range: startRange.upperBound..<templateUrl.endIndex)
        else {
            throw ARCError.invalidURL("Template URL must contain {ipfscid:...} placeholder")
        }

        return String(templateUrl[startRange.lowerBound..<endRange.upperBound])
    }

    /// Resolve the template for a specific asset ID
    public func resolve(assetID: UInt64) throws -> String {
        let cidString = cid.toString()
        var resolved = templateUrl

        // Build the placeholder pattern based on template params
        let placeholder = "{ipfscid:\(templateParams.version.rawValue):\(templateParams.codec.templateString):reserve:\(templateParams.hashAlgorithm)}"

        // Replace the template-ipfs:// scheme and placeholder with ipfs:// and CID
        resolved = resolved.replacingOccurrences(of: "template-ipfs://\(placeholder)", with: "ipfs://\(cidString)")

        // Replace {id} with asset ID
        resolved = resolved.replacingOccurrences(of: "{id}", with: String(assetID))

        return resolved
    }

    /// Resolve to an IPFS URL for a specific asset ID
    public func resolveToIPFSUrl(assetID: UInt64) throws -> IPFSUrl {
        let resolved = try resolve(assetID: assetID)
        return try IPFSUrl(string: resolved)
    }

    public func validate() -> ValidationResult {
        var results: [ValidationResult] = []

        // Validate template URL format
        if !templateUrl.hasPrefix("template-ipfs://") {
            results.append(.failure(
                field: "templateUrl",
                message: "Must use template-ipfs:// scheme"
            ))
        }

        // Validate reserve address format (Algorand address is 58 characters)
        if reserveAddress.count != 58 {
            results.append(.failure(
                field: "reserveAddress",
                message: "Invalid Algorand address length"
            ))
        }

        // Validate that template contains a valid placeholder
        if !templateUrl.contains("{ipfscid:") {
            results.append(.failure(
                field: "templateUrl",
                message: "Must contain {ipfscid:...} placeholder"
            ))
        }

        // Validate that template contains {id} placeholder (warning only)
        if !templateUrl.contains("{id}") {
            results.append(.warning(
                field: "templateUrl",
                message: "Template should contain {id} placeholder for asset ID"
            ))
        }

        return ValidationResult.combine(results)
    }
}

extension ARC19Template: Codable {
    enum CodingKeys: String, CodingKey {
        case templateUrl = "template_url"
        case reserveAddress = "reserve_address"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let templateUrl = try container.decode(String.self, forKey: .templateUrl)
        let reserveAddress = try container.decode(String.self, forKey: .reserveAddress)

        try self.init(templateUrl: templateUrl, reserveAddress: reserveAddress)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(templateUrl, forKey: .templateUrl)
        try container.encode(reserveAddress, forKey: .reserveAddress)
    }
}
