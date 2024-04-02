//
//  NotEqualValidation.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/23.
//

import Foundation

final class NotEqualValidation<T: Equatable>: Validatable {
    
    private let fieldName: String
    private let compareValue: T
    var error: ValidateError?
    
    init(fieldName: String, compareValue: T, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.compareValue = compareValue
        self.error = error
    }
    
    func validate(data: [String : Any]?) -> ValidateError? {
        guard let value = data?[fieldName] as? T,
              value != compareValue else { return error }
        return nil
    }
    
    func validate(value: T) -> ValidateError? {
        return value == compareValue ? error : nil
    }
    
}
