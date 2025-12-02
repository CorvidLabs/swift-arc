import Foundation

/// Fluent builder for ARC-19 templates
public struct ARC19Builder: Sendable {
    private var cid: CID?
    private var pathTemplate: String
    private var reserveAddress: String?

    public init() {
        self.pathTemplate = "/{id}"
    }

    /// Set the CID directly
    public func cid(_ value: CID) -> ARC19Builder {
        var copy = self
        copy.cid = value
        return copy
    }

    /// Set the CID from a string
    public func cid(_ string: String) throws -> ARC19Builder {
        var copy = self
        copy.cid = try CID(string: string)
        return copy
    }

    /// Set the CID from an IPFS URL
    public func ipfsUrl(_ url: IPFSUrl) -> ARC19Builder {
        var copy = self
        copy.cid = url.cid
        return copy
    }

    /// Set the CID from an IPFS URL string
    public func ipfsUrl(_ urlString: String) throws -> ARC19Builder {
        var copy = self
        let url = try IPFSUrl(string: urlString)
        copy.cid = url.cid
        return copy
    }

    /// Set the path template (default is "/{id}")
    public func pathTemplate(_ template: String) -> ARC19Builder {
        var copy = self
        copy.pathTemplate = template
        return copy
    }

    /// Set the reserve address directly
    public func reserveAddress(_ address: String) -> ARC19Builder {
        var copy = self
        copy.reserveAddress = address
        return copy
    }

    /// Build the ARC-19 template
    public func build() throws -> ARC19Template {
        guard let cid else {
            throw ARCError.missingRequiredField("cid")
        }

        // Generate reserve address from CID if not provided
        let address: String
        if let reserveAddress {
            address = reserveAddress
        } else {
            address = try ARC19CID.encodeToReserveAddress(cid: cid)
        }

        let templateUrl = "template-ipfs://{ipfscid:0:dag-pb:reserve:sha2-256}\(pathTemplate)"

        return try ARC19Template(templateUrl: templateUrl, reserveAddress: address)
    }

    /// Validate and build, throwing if validation fails
    public func validated() throws -> ARC19Template {
        let template = try build()
        let result = template.validate()

        guard result.isValid else {
            throw ARCError.validationFailed(result.failures)
        }

        return template
    }
}

extension ARC19Template {
    /// Create a builder from this template
    public func toBuilder() -> ARC19Builder {
        ARC19Builder()
            .cid(cid)
            .reserveAddress(reserveAddress)
    }
}
