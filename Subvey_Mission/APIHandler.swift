//
//  APIHandler.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/01/31.
//

import Foundation

struct APIHandler {
    
    enum ApiType: String {
        case question = "/question"
        case answer = "/answers"
    }
    
    let baseUrl: String = "https://512ab7c7-e29e-4a64-ace6-d1e98a5ce40f.mock.pstmn.io/api"
    func fetchQuestion<T: Codable>(type: T.Type, apiType: ApiType, typeID: String, sendData: [String: Any]? = nil, complete: @escaping (T) -> Void) {
        guard let url = URL(string: baseUrl + apiType.rawValue + "/" + typeID) else { return }
        var request = URLRequest(url: url)
        print(url.absoluteString)
        if apiType == .answer {
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let sendData {
                do {
                    let sendJson = try JSONSerialization.data(withJSONObject: sendData, options: [.prettyPrinted])
                    request.httpBody = sendJson
                } catch let e {
                    print(e.localizedDescription)
                }
            } else {
                print("데이터가 존재하지 않습니다.")
            }
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let data else { return }
            print(String(data: data, encoding: .utf8))
            let decoder = JSONDecoder()
            do {
                let question = try decoder.decode(T.self, from: data)
                complete(question)
            } catch let error as DecodingError {
                switch error {
                case .typeMismatch(_, let context):
                    print("타입 불일치: \(context.debugDescription)")
                    print("코딩 키 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: ", "))")
                case .valueNotFound(_, let context):
                    print("값을 찾을 수 없음: \(context.debugDescription)")
                    print("코딩 키 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: ", "))")
                case .keyNotFound(_, let context):
                    print("키를 찾을 수 없음: \(context.debugDescription)")
                    print("코딩 키 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: ", "))")
                case .dataCorrupted(let context):
                    print("손상된 데이터: \(context.debugDescription)")
                    print("코딩 키 경로: \(context.codingPath.map { $0.stringValue }.joined(separator: ", "))")
                default:
                    print("다른 오류: \(error.localizedDescription)")
                }
            } catch {
                print("알 수 없는 오류: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct Question: Codable {
    let status: Int
    let data: QuestionInfo
}

struct QuestionInfo: Codable {
    let forms: [Form]
    let escapeValidate: [EscapeValidate]
}

struct Form: Codable {
    let name: String
    let question: String
    let required: Bool
    let type: String
    let placeholder: MultiValue
    let validate: [Validate]
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

struct Answer: Codable {
    let status: Int
    let data: AnswerInfo
}

struct AnswerInfo: Codable {
    let isSuccess: Bool
    let nextTypeId: String?
}
