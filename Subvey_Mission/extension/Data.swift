//
//  Data.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/03/20.
//

import Foundation

extension Data {
    func decode<T: Decodable> () -> T? {
        let decoder = JSONDecoder()
        do {
            let answer = try decoder.decode(T.self, from: self)
            return answer
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
            return nil
        } catch {
            print("알 수 없는 오류: \(error.localizedDescription)")
            return nil
        }
    }
}
