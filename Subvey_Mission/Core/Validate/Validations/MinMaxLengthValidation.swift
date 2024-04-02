//
//  MinMaxValidation.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/23.
//

import Foundation

final class MinMaxLengthValidation: Validatable {
        
    private let fieldName: String
    private let minLength: Int
    private let maxLength: Int
    
    var error: ValidateError?
    
    init(fieldName: String, minLength: Int, maxLength: Int, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.minLength = minLength
        self.maxLength = maxLength
        self.error = error
    }
    
    func validate(data: [String: Any]?) -> ValidateError? {
        guard let text = data?[fieldName] as? String else { return error }
        let length = text.count
        if length > maxLength || length < minLength { return error }
        return nil
    }
    
    func validate(value: String) -> ValidateError? {
        guard value.count >= minLength || value.count <= maxLength else { return error }
        return nil
    }
}
