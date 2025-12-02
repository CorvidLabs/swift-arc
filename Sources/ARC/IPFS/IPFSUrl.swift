import Foundation

/// Represents an IPFS URL with parsing and manipulation capabilities
public struct IPFSUrl: Sendable, Equatable, Hashable {
    public let scheme: Scheme
    public let cid: CID
    public let path: String?

    public enum Scheme: String, Sendable {
        case ipfs = "ipfs"
        case templateIPFS = "template-ipfs"
    }

    public init(scheme: Scheme, cid: CID, path: String? = nil) {
        self.scheme = scheme
        self.cid = cid
        self.path = path
    }

    /// Parse an IPFS URL string
    public init(string: String) throws {
        // Parse scheme
        guard let schemeEnd = string.range(of: "://") else {
            throw ARCError.invalidURL("Missing :// in URL")
        }

        let schemeString = String(string[..<schemeEnd.lowerBound])
        guard let scheme = Scheme(rawValue: schemeString) else {
            throw ARCError.invalidURL("Invalid scheme: \(schemeString)")
        }
        self.scheme = scheme

        // Parse CID and path
        let remainder = String(string[schemeEnd.upperBound...])
        let components = remainder.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)

        guard let cidString = components.first, !cidString.isEmpty else {
            throw ARCError.invalidURL("Missing CID in URL")
        }

        self.cid = try CID(string: String(cidString))

        if components.count > 1 {
            self.path = "/" + String(components[1])
        } else {
            self.path = nil
        }
    }

    /// Convert to URL string
    public func toString() -> String {
        var result = "\(scheme.rawValue)://\(cid.toString())"
        if let path {
            result += path
        }
        return result
    }

    /// Convert to HTTP gateway URL
    public func toGatewayURL(gateway: String = "https://gateway.pinata.cloud") -> String {
        var result = "\(gateway)/ipfs/\(cid.toString())"
        if let path {
            result += path
        }
        return result
    }

    /// Replace template variables in the URL path
    /// For ARC-19, {id} is replaced with the asset ID
    public func resolveTemplate(variables: [String: String]) -> IPFSUrl {
        guard let path else { return self }

        var resolvedPath = path
        for (key, value) in variables {
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: value)
        }

        return IPFSUrl(scheme: scheme, cid: cid, path: resolvedPath)
    }

    /// Resolve ARC-19 template with asset ID
    public func resolveARC19Template(assetID: UInt64) -> IPFSUrl {
        resolveTemplate(variables: ["id": String(assetID)])
    }
}

extension IPFSUrl: CustomStringConvertible {
    public var description: String {
        toString()
    }
}

extension IPFSUrl: LosslessStringConvertible {
    public init?(_ description: String) {
        try? self.init(string: description)
    }
}

extension IPFSUrl: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        try self.init(string: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toString())
    }
}
