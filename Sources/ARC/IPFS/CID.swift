import Foundation

/// Content Identifier (CID) for IPFS
/// Supports CIDv0 (Base58) and CIDv1 (Base32)
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

    /// Parse a CID string
    public init(string: String) throws {
        if string.hasPrefix("Qm") {
            // CIDv0: Base58 encoded multihash
            let decoded = try Base58.decode(string)

            // Multihash format: <hash-fn-code><digest-size><digest>
            // SHA2-256: 0x12 (18) + 0x20 (32) + 32 bytes = 34 bytes
            guard decoded.count >= 34,
                  decoded[0] == 0x12,
                  decoded[1] == 0x20
            else {
                throw ARCError.invalidCID("Invalid CIDv0 multihash format")
            }

            self.version = .v0
            self.codec = .dagPB
            self.hash = Data(decoded[2...])
        } else if string.hasPrefix("b") {
            // CIDv1: Base32 encoded
            let base32Part = String(string.dropFirst())
            let decoded = try Base32.decode(base32Part.lowercased())

            guard decoded.count > 4 else {
                throw ARCError.invalidCID("CIDv1 too short")
            }

            // CIDv1 format: <version><codec><multihash>
            guard decoded[0] == 0x01 else {
                throw ARCError.invalidCID("Invalid CIDv1 version byte")
            }

            // Parse codec varint
            var offset = 1
            var codecValue: UInt64 = 0
            var shift = 0

            while offset < decoded.count {
                let byte = decoded[offset]
                codecValue |= UInt64(byte & 0x7F) << shift
                offset += 1
                if byte & 0x80 == 0 { break }
                shift += 7
            }

            let codec: Codec
            switch codecValue {
            case 0x55: codec = .raw
            case 0x70: codec = .dagPB
            case 0x71: codec = .dagCBOR
            case 0x0129: codec = .dagJSON
            default:
                throw ARCError.invalidCID("Unsupported codec: \(codecValue)")
            }

            // Parse multihash
            guard offset + 2 <= decoded.count,
                  decoded[offset] == 0x12,
                  decoded[offset + 1] == 0x20
            else {
                throw ARCError.invalidCID("Invalid CIDv1 multihash")
            }

            guard offset + 34 <= decoded.count else {
                throw ARCError.invalidCID("CIDv1 hash too short")
            }

            self.version = .v1
            self.codec = codec
            self.hash = Data(decoded[(offset + 2)..<(offset + 34)])
        } else if string.hasPrefix("z") {
            // CIDv1 with Base58 (less common)
            let base58Part = String(string.dropFirst())
            let decoded = try Base58.decode(base58Part)

            guard decoded.count > 4, decoded[0] == 0x01 else {
                throw ARCError.invalidCID("Invalid CIDv1 (base58) format")
            }

            // Parse codec varint
            var offset = 1
            var codecValue: UInt64 = 0
            var shift = 0

            while offset < decoded.count {
                let byte = decoded[offset]
                codecValue |= UInt64(byte & 0x7F) << shift
                offset += 1
                if byte & 0x80 == 0 { break }
                shift += 7
            }

            let codec: Codec
            switch codecValue {
            case 0x55: codec = .raw
            case 0x70: codec = .dagPB
            case 0x71: codec = .dagCBOR
            case 0x0129: codec = .dagJSON
            default:
                throw ARCError.invalidCID("Unsupported codec: \(codecValue)")
            }

            guard offset + 34 <= decoded.count,
                  decoded[offset] == 0x12,
                  decoded[offset + 1] == 0x20
            else {
                throw ARCError.invalidCID("Invalid CIDv1 (base58) multihash")
            }

            self.version = .v1
            self.codec = codec
            self.hash = Data(decoded[(offset + 2)..<(offset + 34)])
        } else {
            throw ARCError.invalidCID("CID must start with 'Qm' (v0), 'b' or 'z' (v1)")
        }
    }

    /// Encode the CID to a string
    public func toString() -> String {
        guard hash.count == 32 else {
            // Fallback for invalid hash size
            return version == .v0 ? "Qm" : "b"
        }

        // Create multihash: SHA2-256 (0x12) + 32 bytes (0x20) + hash
        var multihash = Data([0x12, 0x20])
        multihash.append(hash)

        if version == .v0 {
            // CIDv0: Base58 encoded multihash
            return Base58.encode(Array(multihash))
        } else {
            // CIDv1: version + codec + multihash in Base32
            var cidBytes = Data()
            cidBytes.append(0x01) // Version 1

            // Encode codec as varint
            cidBytes.append(contentsOf: encodeVarint(codec.rawValue))
            cidBytes.append(multihash)

            return "b" + Base32.encode(Array(cidBytes))
        }
    }

    private func encodeVarint(_ value: UInt64) -> [UInt8] {
        var result: [UInt8] = []
        var val = value

        while val >= 0x80 {
            result.append(UInt8((val & 0x7F) | 0x80))
            val >>= 7
        }
        result.append(UInt8(val))

        return result
    }
}

// MARK: - Base58 Encoder/Decoder

private enum Base58 {
    private static let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    private static let alphabetString = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    static func encode(_ bytes: [UInt8]) -> String {
        var leadingZeros = 0
        for byte in bytes {
            if byte == 0 { leadingZeros += 1 }
            else { break }
        }

        let size = bytes.count * 138 / 100 + 1
        var result = [UInt8](repeating: 0, count: size)
        var length = 0

        for byte in bytes {
            var carry = Int(byte)
            var i = 0

            for j in stride(from: size - 1, through: 0, by: -1) {
                if carry == 0 && i >= length { break }
                carry += 256 * Int(result[j])
                result[j] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }
            length = i
        }

        var startIndex = 0
        while startIndex < size && result[startIndex] == 0 {
            startIndex += 1
        }

        var output = String(repeating: "1", count: leadingZeros)
        for i in startIndex..<size {
            output.append(alphabet[Int(result[i])])
        }

        return output
    }

    static func decode(_ string: String) throws -> [UInt8] {
        var result: [UInt8] = [0]

        for char in string {
            guard let index = alphabetString.firstIndex(of: char) else {
                throw ARCError.invalidCID("Invalid Base58 character: \(char)")
            }

            var carry = alphabetString.distance(from: alphabetString.startIndex, to: index)

            for i in 0..<result.count {
                carry += 58 * Int(result[result.count - 1 - i])
                result[result.count - 1 - i] = UInt8(carry % 256)
                carry /= 256
            }

            while carry > 0 {
                result.insert(UInt8(carry % 256), at: 0)
                carry /= 256
            }
        }

        for char in string {
            if char != "1" { break }
            result.insert(0, at: 0)
        }

        return result
    }
}

// MARK: - Base32 Encoder/Decoder (RFC 4648 lowercase)

private enum Base32 {
    private static let alphabet = Array("abcdefghijklmnopqrstuvwxyz234567")
    private static let alphabetString = "abcdefghijklmnopqrstuvwxyz234567"

    static func encode(_ bytes: [UInt8]) -> String {
        var result = ""
        var bits = 0
        var value = 0

        for byte in bytes {
            value = (value << 8) | Int(byte)
            bits += 8

            while bits >= 5 {
                bits -= 5
                let index = (value >> bits) & 0x1F
                result.append(alphabet[index])
            }
        }

        if bits > 0 {
            let index = (value << (5 - bits)) & 0x1F
            result.append(alphabet[index])
        }

        return result
    }

    static func decode(_ string: String) throws -> [UInt8] {
        var bits = 0
        var value = 0
        var result: [UInt8] = []

        for char in string {
            if char == "=" { break }

            guard let index = alphabetString.firstIndex(of: char) else {
                throw ARCError.invalidCID("Invalid Base32 character: \(char)")
            }

            value = (value << 5) | alphabetString.distance(from: alphabetString.startIndex, to: index)
            bits += 5

            if bits >= 8 {
                bits -= 8
                result.append(UInt8((value >> bits) & 0xFF))
            }
        }

        return result
    }
}
