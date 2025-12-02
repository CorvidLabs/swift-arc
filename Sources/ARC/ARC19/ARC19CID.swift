import Foundation
import Crypto

/// Utilities for working with ARC-19 CID encoding in reserve addresses
public enum ARC19CID {
    /// Extract a CID from an Algorand reserve address
    /// The CID is encoded in the public key part of the address
    public static func extractCID(from address: String) throws -> CID {
        // Decode the Algorand address
        let decoded = try decodeAlgorandAddress(address)

        // The first 32 bytes are the public key (which contains the CID)
        guard decoded.count >= 32 else {
            throw ARCError.invalidReserveAddress("Address too short")
        }

        let publicKey = decoded.prefix(32)

        // For ARC-19, we expect a SHA-256 hash (32 bytes)
        // This represents a CIDv0 (dag-pb)
        return CID(version: .v0, codec: .dagPB, hash: Data(publicKey))
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

    private static func decodeAlgorandAddress(_ address: String) throws -> Data {
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

        // Verify checksum
        let publicKey = result.prefix(32)
        let checksum = result.suffix(4)
        let expectedChecksum = computeChecksum(publicKey)

        guard checksum == expectedChecksum else {
            throw ARCError.invalidReserveAddress("Invalid address checksum")
        }

        return publicKey
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
