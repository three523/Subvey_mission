//
//  SubveyError.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/03/19.
//

import Foundation

struct SubveyErrorData: Codable, Error {
    var name: String
    var message: String
    var header: String
}

enum SubveyError: Error {
    case notConnectedToInternet
    case notFound(SubveyErrorData)
    case mockServerRequest(SubveyErrorData)
    case serverError
    case decodingError
    case unknowError
    case postError
}

extension SubveyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConnectedToInternet:
            return "인터넷 연결이 불안정 합니다."
        case .notFound(let data):
            return data.message
        case .mockServerRequest(let data):
            return data.message
        case .serverError:
            return "서버에 문제가 생겼습니다."
        case .decodingError:
            return "디코딩에 문제가 있습니다."
        case .unknowError:
            return "알수없는 에러"
        case .postError:
            return "서버에 전달 실패"
        }
    }
}
