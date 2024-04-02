
/*
 네트워크 통신 관련 클래스
*/

import Foundation

struct APIHandler {
    
    enum ApiType: String {
        case question = "/question/"
        case answer = "/answers/"
    }
    
    let baseUrl: String = "https://512ab7c7-e29e-4a64-ace6-d1e98a5ce40f.mock.pstmn.io/api"
    
    func fetchSubvey(typeID: String, completion: @escaping (Result<Subvey, NetworkError>) -> Void) {
        guard let url = URL(string: baseUrl + ApiType.question.rawValue + typeID) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(findNetworkErrorType(error: error)))
                return
            }
            guard let data else { return }
            
            // Postman mockServer의 경로를 찾을수 없는 경우
            if let subveyError = networkFaileDecoding(data: data) {
                completion(.failure(subveyError))
                return
            }
                        
            if let subvey: Subvey = data.decode() {
                completion(.success(subvey))
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func submitSubery(typeId: String, sendData: [String: Any], completion: @escaping (Result<Answer, NetworkError>) -> Void) {
        guard let url = URL(string: baseUrl + ApiType.answer.rawValue + typeId) else { return }
        var request = URLRequest(url: url)
                
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
                completion(.failure(findNetworkErrorType(error: error)))
                return
            }
            guard let data else { return }
            
            if let subveyError = networkFaileDecoding(data: data) {
                completion(.failure(subveyError))
                return
            }
                        
            if let answer: Answer = data.decode() {
                if answer.data.isSuccess {
                    completion(.success(answer))
                } else if !answer.data.isSuccess {
                    completion(.failure(.postError))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // Postman mockServer에 문제가 생긴경우 NetworkErrorData 타입의 형태로 디코딩 작업 해야해서 아래 코드가 필요함
    private func networkFaileDecoding(data: Data) -> NetworkError? {
        let decoder = JSONDecoder()
        if let subveyError = try? decoder.decode(NetworkErrorData.self, from: data) {
            if subveyError.header == "mockRequestNotFoundError" {
                return .notFound(subveyError)
            } else {
                return .mockServerRequest(subveyError)
            }
        }
        return nil
    }
    
    private func findNetworkErrorType(error: Error) -> NetworkError {
        print("error: \(error.localizedDescription)")
        if (error as NSError).domain == NSURLErrorDomain {
            return .notConnectedToInternet
        } else {
            return .unknowError
        }
    }
}
