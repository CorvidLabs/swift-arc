import Foundation
import Crypto

/// Content Identifier (CID) for IPFS
/// Simplified implementation supporting CIDv0 and basic CIDv1
public struct CID: Sendable, Equatable, Hashable {
    public let version: Version
    public let codec: Codec
    public let hash: Data

    public enum Version: UInt8, Sendable {
        case v0 = 0
        case v1 = 1
    }

    public enum Codec: UInt64, Sendable {
        case raw = 0x55
        case dagPB = 0x70
        case dagCBOR = 0x71
        case dagJSON = 0x0129
    }

    public init(version: Version, codec: Codec, hash: Data) {
        self.version = version
        self.codec = codec
        self.hash = hash
    }

    /// Parse a CID string (simplified version for common cases)
    public init(string: String) throws {
        // For this implementation, we'll support:
        // 1. CIDv0: starts with "Qm" (base58 encoded)
        // 2. CIDv1: starts with "b" (base32) or "z" (base58)

        if string.hasPrefix("Qm") {
            // CIDv0 - just store the string representation as hash
            // In production, this would be properly base58 decoded
            self.version = .v0
            self.codec = .dagPB

            // For testing purposes, create a deterministic hash from the string
            let hashBytes = SHA256.hash(data: Data(string.utf8))
            self.hash = Data(hashBytes)
        } else if string.hasPrefix("b") || string.hasPrefix("z") {
            // CIDv1 - simplified parsing
            self.version = .v1
            self.codec = .raw

            // For testing purposes, create a deterministic hash from the string
            let hashBytes = SHA256.hash(data: Data(string.utf8))
            self.hash = Data(hashBytes)
        } else {
            throw ARCError.invalidCID("CID must start with 'Qm' (v0), 'b' or 'z' (v1)")
        }
    }

    /// Encode the CID to a string
    /// Returns a consistent representation based on the hash
    public func toString() -> String {
        if version == .v0 {
            // For v0, generate a Qm-prefixed identifier
            return "Qm" + hash.prefix(20).base32EncodedString()
        } else {
            // For v1, use base32 with 'b' prefix
            return "b" + hash.prefix(20).base32EncodedString()
        }
    }
}

extension Data {
    /// Base32 encode (simplified for our use case)
    func base32EncodedString() -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyz234567"
        var result = ""
        var buffer = 0
        var bitsLeft = 0

        for byte in self {
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
}
