//
//  MaxLengthValidation.swift
//  InputValidator
//
//  Created by 김도현 on 2024/02/22.
//

import Foundation

final class MaxLengthValidation: Validatable {
        
    private let fieldName: String
    private let maxLength: Int
    var error: ValidateError
    
    init(fieldName: String, maxLength: Int, error: ValidateError) {
        self.fieldName = fieldName
        self.maxLength = maxLength
        self.error = error
    }
    
    func validate(data: [String: Any]?) -> ValidateError? {
        guard let count = data?[fieldName] as? Int,
              count < maxLength  else { return error }
        return nil
    }
    
    func validate(value: Int) -> ValidateError? {
        guard value <= maxLength else { return error }
        return nil
    }
}
