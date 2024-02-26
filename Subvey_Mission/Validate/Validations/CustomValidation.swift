//
//  CustomValidation.swift
//  FormManager
//
//  Created by 김도현 on 2024/01/13.
//

import Foundation

final class CustomValidation: Validatable {
        
    private let fieldName: String
    private let customValidator: Validator
    var error: ValidateError?
    
    init(fieldName: String, pattern: String, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.customValidator = CustomValidator(pattern: pattern)
        self.error = error
    }
    
    func validate(data: [String : Any]?) -> ValidateError? {
        guard let value = data?[fieldName] as? String,
              customValidator.isValid(text: value) else { return error }
        return nil
    }
    
    func validate(value: String) -> ValidateError? {
        guard customValidator.isValid(text: value) else { return error }
        return nil
    }
}
