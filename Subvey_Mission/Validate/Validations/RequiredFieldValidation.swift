//
//  RequeridInput.swift
//  InputManager
//
//  Created by 김도현 on 2024/01/07.
//

import Foundation

final class RequiredFieldValidation<InputType>: Validatable {
    private let fieldName: String
    var error: ValidateError
    
    init(fieldName: String, error: ValidateError) {
        self.fieldName = fieldName
        self.error = error
    }
    
    func validate(value: InputType?) -> ValidateError? {
        return value == nil ? error : nil
    }
}
