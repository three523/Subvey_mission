//
//  MinLengthValidation.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/23.
//

import Foundation

final class MinLengthValidation: Validatable {
        
    private let fieldName: String
    private let minLength: Int
    var error: ValidateError
    
    init(fieldName: String, minLength: Int, error: ValidateError) {
        self.fieldName = fieldName
        self.minLength = minLength
        self.error = error
    }
    
    func validate(data: [String: Any]?) -> ValidateError? {
        guard let count = data?[fieldName] as? Int,
              count < minLength  else { return error }
        return nil
    }
    
    func validate(value: Int) -> ValidateError? {
        guard value >= minLength else { return error }
        return nil
    }
}

