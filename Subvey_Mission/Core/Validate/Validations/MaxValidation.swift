//
//  MaxLengthValidation.swift
//  InputValidator
//
//  Created by 김도현 on 2024/02/22.
//

import Foundation

final class MaxValidation: Validatable {
        
    private let fieldName: String
    private let maxLength: Int
    var error: ValidateError?
    
    init(fieldName: String, maxLength: Int, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.maxLength = maxLength
        self.error = error
    }
    
    func validate(data: [String: Any]?) -> ValidateError? {
        guard let count = data?[fieldName] as? Int,
              count <= maxLength  else { return error }
        return nil
    }
    
    func validate(value: Int) -> ValidateError? {
        guard value <= maxLength else { return error }
        return nil
    }
}
