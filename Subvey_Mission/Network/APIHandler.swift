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
    
    func fetchSubvey(typeID: String, complete: @escaping (Result<Subvey, Error>) -> Void) {
        guard let url = URL(string: baseUrl + "/question/" + typeID) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let data else { return }
            let decoder = JSONDecoder()
            do {
                let question = try decoder.decode(Subvey.self, from: data)
                complete(.success(question))
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
    
    func submitSubery(typeId: String, sendData: [String: Any], completion: @escaping (Result<Answer, Error>) -> Void) {
        guard let url = URL(string: baseUrl + "/answers/" + typeId) else { return }
        var request = URLRequest(url: url)
        
        print(sendData)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let sendJson = try JSONSerialization.data(withJSONObject: sendData, options: [.prettyPrinted])
            request.httpBody = sendJson
        } catch let e {
            print(e.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let data else { return }
            let decoder = JSONDecoder()
            do {
                let answer = try decoder.decode(Answer.self, from: data)
                if answer.data.isSuccess {
                    completion(.success(answer))
                } else if !answer.data.isSuccess {
                    //TODO: 설문 전달 실패 에러 처리
                    print("설문내용 전달 실패")
                }
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
