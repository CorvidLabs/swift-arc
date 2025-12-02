import Foundation

/// Represents a JSON property value that can be string, number, or object
public enum PropertyValue: Sendable, Equatable {
    case string(String)
    case number(Double)
    case object([String: PropertyValue])

    /// Create a property value from a string
    public static func text(_ value: String) -> PropertyValue {
        .string(value)
    }

    /// Create a property value from a number
    public static func numeric(_ value: Double) -> PropertyValue {
        .number(value)
    }

    /// Create a property value from an integer
    public static func integer(_ value: Int) -> PropertyValue {
        .number(Double(value))
    }

    /// Create a property value from a dictionary
    public static func dictionary(_ value: [String: PropertyValue]) -> PropertyValue {
        .object(value)
    }
}

extension PropertyValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let object = try? container.decode([String: PropertyValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "PropertyValue must be string, number, or object"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}

extension PropertyValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension PropertyValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension PropertyValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension PropertyValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, PropertyValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}
