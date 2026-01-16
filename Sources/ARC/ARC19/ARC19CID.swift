import Foundation
import Crypto

/// Utilities for working with ARC-19 CID encoding in reserve addresses
public enum ARC19CID {
    /// Parameters parsed from an ARC-19 template placeholder
    public struct TemplateParams: Sendable, Equatable {
        public let version: CID.Version
        public let codec: CID.Codec
        public let hashAlgorithm: String

        public init(version: CID.Version, codec: CID.Codec, hashAlgorithm: String = "sha2-256") {
            self.version = version
            self.codec = codec
            self.hashAlgorithm = hashAlgorithm
        }

        /// Default parameters for CIDv0 dag-pb
        public static let v0DagPB = TemplateParams(version: .v0, codec: .dagPB)

        /// Default parameters for CIDv1 raw
        public static let v1Raw = TemplateParams(version: .v1, codec: .raw)
    }

    /// Parse template parameters from an ARC-19 placeholder string
    /// Format: {ipfscid:<version>:<codec>:reserve:<hash>}
    /// Examples:
    ///   - {ipfscid:0:dag-pb:reserve:sha2-256}
    ///   - {ipfscid:1:raw:reserve:sha2-256}
    public static func parseTemplateParams(from placeholder: String) throws -> TemplateParams {
        // Remove braces if present
        var content = placeholder
        if content.hasPrefix("{") && content.hasSuffix("}") {
            content = String(content.dropFirst().dropLast())
        }

        let parts = content.split(separator: ":")
        guard parts.count >= 5,
              parts[0] == "ipfscid",
              parts[3] == "reserve"
        else {
            throw ARCError.invalidURL("Invalid ARC-19 template placeholder format: \(placeholder)")
        }

        // Parse version with strict validation
        let versionStr = String(parts[1])
        guard let versionNum = Int(versionStr), versionNum == 0 || versionNum == 1 else {
            throw ARCError.invalidURL("Unsupported CID version in ARC-19 template: \(versionStr)")
        }
        let version: CID.Version = versionNum == 1 ? .v1 : .v0

        // Parse codec using extension
        let codec = try CID.Codec(templateString: String(parts[2]))

        // Parse hash algorithm
        let hashAlgorithm = String(parts[4])

        return TemplateParams(version: version, codec: codec, hashAlgorithm: hashAlgorithm)
    }

    /// Extract a CID from an Algorand reserve address
    /// - Parameters:
    ///   - address: The Algorand reserve address containing the encoded CID
    ///   - params: Optional template parameters specifying CID version and codec
    ///   - validateChecksum: Whether to validate the Algorand address checksum (default: false for ARC-19)
    /// - Returns: The extracted CID
    public static func extractCID(
        from address: String,
        params: TemplateParams = .v0DagPB,
        validateChecksum: Bool = false
    ) throws -> CID {
        // Decode the Algorand address
        let decoded = try decodeAlgorandAddress(address, validateChecksum: validateChecksum)

        // The first 32 bytes are the public key (which contains the CID hash)
        guard decoded.count >= 32 else {
            throw ARCError.invalidReserveAddress("Address too short")
        }

        let hash = Data(decoded.prefix(32))

        return CID(version: params.version, codec: params.codec, hash: hash)
    }

    /// Extract a CID from an Algorand reserve address using template URL to determine parameters
    /// - Parameters:
    ///   - address: The Algorand reserve address containing the encoded CID
    ///   - templateUrl: The template URL containing the placeholder with version/codec info
    /// - Returns: The extracted CID
    public static func extractCID(from address: String, templateUrl: String) throws -> CID {
        let params = try parseParamsFromTemplate(templateUrl)
        return try extractCID(from: address, params: params, validateChecksum: false)
    }

    /// Parse template parameters from a full template URL
    private static func parseParamsFromTemplate(_ templateUrl: String) throws -> TemplateParams {
        // Find the placeholder pattern {ipfscid:...}
        guard let startRange = templateUrl.range(of: "{ipfscid:"),
              let endRange = templateUrl.range(of: "}", range: startRange.upperBound..<templateUrl.endIndex)
        else {
            // Default to v0 dag-pb if no placeholder found
            return .v0DagPB
        }

        let placeholder = String(templateUrl[startRange.lowerBound..<endRange.upperBound])
        return try parseTemplateParams(from: placeholder)
    }

    /// Encode a CID into an Algorand reserve address
    public static func encodeToReserveAddress(cid: CID) throws -> String {
        guard cid.hash.count == 32 else {
            throw ARCError.invalidCID("CID hash must be 32 bytes for ARC-19")
        }

        // Use the CID hash as the public key
        return try encodeAlgorandAddress(Data(cid.hash))
    }

    // MARK: - Algorand Address Encoding/Decoding

    private static func decodeAlgorandAddress(_ address: String, validateChecksum: Bool) throws -> Data {
        // Algorand addresses are base32 encoded (without padding)
        // They contain: 32 bytes public key + 4 bytes checksum

        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        var result = Data()
        var buffer = 0
        var bitsLeft = 0

        for char in address.uppercased() {
            guard let index = alphabet.firstIndex(of: char) else {
                throw ARCError.invalidReserveAddress("Invalid character in address: \(char)")
            }

            buffer = (buffer << 5) | alphabet.distance(from: alphabet.startIndex, to: index)
            bitsLeft += 5

            if bitsLeft >= 8 {
                bitsLeft -= 8
                result.append(UInt8((buffer >> bitsLeft) & 0xFF))
            }
        }

        guard result.count == 36 else {
            throw ARCError.invalidReserveAddress("Invalid address length after decoding")
        }

        let publicKey = result.prefix(32)

        // Optionally verify checksum
        if validateChecksum {
            let checksum = result.suffix(4)
            let expectedChecksum = computeChecksum(publicKey)

            guard checksum == expectedChecksum else {
                throw ARCError.invalidReserveAddress("Invalid address checksum")
            }
        }

        return Data(publicKey)
    }

    private static func encodeAlgorandAddress(_ publicKey: Data) throws -> String {
        guard publicKey.count == 32 else {
            throw ARCError.invalidReserveAddress("Public key must be 32 bytes")
        }

        // Compute checksum
        let checksum = computeChecksum(publicKey)

        // Combine public key and checksum
        var combined = publicKey
        combined.append(checksum)

        // Base32 encode
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        var result = ""
        var buffer = 0
        var bitsLeft = 0

        for byte in combined {
            buffer = (buffer << 8) | Int(byte)
            bitsLeft += 8

            while bitsLeft >= 5 {
                bitsLeft -= 5
                let index = (buffer >> bitsLeft) & 0x1F
                let char = alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)]
                result.append(char)
            }
        }

        if bitsLeft > 0 {
            buffer <<= (5 - bitsLeft)
            let index = buffer & 0x1F
            let char = alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)]
            result.append(char)
        }

        return result
    }

    private static func computeChecksum(_ data: Data) -> Data {
        // Algorand uses SHA-512/256 for checksums (last 4 bytes)
        let hash = SHA512.hash(data: data)
        let hashData = Data(hash)

        // Take first 32 bytes (SHA-512/256), then last 4 bytes as checksum
        return hashData.prefix(32).suffix(4)
    }
}
