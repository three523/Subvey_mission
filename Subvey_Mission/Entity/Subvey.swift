//
//  Subvey.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/08.
//

import Foundation

struct Subvey: Codable {
    let status: Int
    let data: Question
}

struct Question: Codable {
    let forms: [Form]
    let escapeValidate: [EscapeValidate]
}

struct Form: Codable {
    let name: String
    let question: String
    let required: Bool
    let type: FormType
    let placeholder: MultiValue
    let validate: [Validate]
}

enum FormType: String, Codable {
    case text
    case number
    case checkbox
    case radio
    case radioNumber
    case radioWithInput
}

struct Validate: Codable {
    let type: String
    let target: Target
    let validateText: String
}

struct EscapeValidate: Codable {
    let name: String
    let type: String
    let target: Target
}

enum MultiValue: Codable {
    case int(Int)
    case string(String)
    case bool(Bool)
    case dictionary([Option])
    
    struct Option: Codable {
        let label: String
        let value: String
        let checked: Bool
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let dictionaryValue = try? container.decode([Option].self) {
            self = .dictionary(dictionaryValue)
        } else {
            throw DecodingError.typeMismatch(
                MultiValue.self,
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "지원되는 타입이 아닙니다.")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intValue):
            try container.encode(intValue)
        case .string(let stringValue):
            try container.encode(stringValue)
        case .bool(let boolValue):
            try container.encode(boolValue)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }
}

enum MinMaxValue: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self), stringValue == "-" {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                MinMaxValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid type for MinMaxValue")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}

enum Target: Codable {
    case string(String)
    case int(Int)
    case minMax([MinMaxValue])
    case intArray([Int])
    case stringArray([String])
    case boolArray([Bool])
    case emptyArray

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .emptyArray
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let minMaxValues = try? container.decode([MinMaxValue].self) {
            self = .minMax(minMaxValues)
        } else if let intArray = try? container.decode([Int].self) {
            self = .intArray(intArray)
        } else if let stringArray = try? container.decode([String].self) {
            self = .stringArray(stringArray)
        } else if let boolArray = try? container.decode([Bool].self) {
            self = .boolArray(boolArray)
        } else {
            throw DecodingError.typeMismatch(
                Target.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid type for Target")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .minMax(let values):
            try container.encode(values)
        case .intArray(let values):
            try container.encode(values)
        case .stringArray(let values):
            try container.encode(values)
        case .boolArray(let values):
            try container.encode(values)
        case .emptyArray:
            try container.encode([String]())
        }
    }
}
