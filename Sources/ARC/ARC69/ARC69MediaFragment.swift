import Foundation

/// Media fragment identifiers for ARC-69
/// These fragments specify the media type within a URL
public enum ARC69MediaFragment: String, Sendable, Equatable, CaseIterable {
    /// Image fragment (#i)
    case image = "i"

    /// Video fragment (#v)
    case video = "v"

    /// Audio fragment (#a)
    case audio = "a"

    /// PDF fragment (#p)
    case pdf = "p"

    /// HTML fragment (#h)
    case html = "h"

    /// The fragment identifier with hash
    public var identifier: String {
        "#\(rawValue)"
    }

    /// MIME type prefix associated with this fragment
    public var mimeTypePrefix: String {
        switch self {
        case .image:
            return "image/"
        case .video:
            return "video/"
        case .audio:
            return "audio/"
        case .pdf:
            return "application/pdf"
        case .html:
            return "text/html"
        }
    }

    /// Extract the media fragment from a URL string
    public static func extract(from urlString: String) throws -> ARC69MediaFragment? {
        guard let fragmentRange = urlString.range(of: "#") else {
            return nil
        }

        let fragment = String(urlString[fragmentRange.upperBound...])

        // Fragment should be a single character
        guard fragment.count == 1, let char = fragment.first else {
            throw ARCError.invalidMediaFragment("Fragment must be a single character")
        }

        guard let mediaFragment = ARC69MediaFragment(rawValue: String(char)) else {
            throw ARCError.invalidMediaFragment("Invalid media fragment: \(char)")
        }

        return mediaFragment
    }

    /// Remove the fragment from a URL string
    public static func removeFragment(from urlString: String) -> String {
        guard let fragmentRange = urlString.range(of: "#") else {
            return urlString
        }

        return String(urlString[..<fragmentRange.lowerBound])
    }

    /// Add or replace the fragment in a URL string
    public func apply(to urlString: String) -> String {
        let baseUrl = ARC69MediaFragment.removeFragment(from: urlString)
        return baseUrl + identifier
    }

    /// Validate that the fragment matches the given MIME type
    public func matches(mimeType: String) -> Bool {
        switch self {
        case .image:
            return mimeType.hasPrefix("image/")
        case .video:
            return mimeType.hasPrefix("video/")
        case .audio:
            return mimeType.hasPrefix("audio/")
        case .pdf:
            return mimeType == "application/pdf"
        case .html:
            return mimeType == "text/html"
        }
    }

    /// Infer the media fragment from a MIME type
    public static func infer(from mimeType: String) -> ARC69MediaFragment? {
        if mimeType.hasPrefix("image/") {
            return .image
        } else if mimeType.hasPrefix("video/") {
            return .video
        } else if mimeType.hasPrefix("audio/") {
            return .audio
        } else if mimeType == "application/pdf" {
            return .pdf
        } else if mimeType == "text/html" {
            return .html
        }
        return nil
    }
}

extension ARC69MediaFragment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        case .pdf: return "PDF"
        case .html: return "HTML"
        }
    }
}
