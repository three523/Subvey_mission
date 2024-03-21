//
//  MinMaxCountValidation.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/03/20.
//

import Foundation

final class MinMaxArrayCountValidation<T: Equatable>: Validatable {
        
    private let fieldName: String
    private let minCount: Int
    private let maxCount: Int
    
    var error: ValidateError?
    
    init(fieldName: String, minCount: Int, maxCount: Int, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.minCount = minCount
        self.maxCount = maxCount
        self.error = error
    }
    
    func validate(data: [String: Any]?) -> ValidateError? {
        guard let text = data?[fieldName] as? [T] else { return error }
        let length = text.count
        if length > maxCount || length < minCount { return error }
        return nil
    }
    
    func validate(value: [T]) -> ValidateError? {
        guard value.count >= minCount || value.count <= maxCount else { return error }
        return nil
    }
}
