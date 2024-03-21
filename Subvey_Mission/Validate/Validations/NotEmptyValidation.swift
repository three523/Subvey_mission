//
//  NotEmptyValidation.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/03/20.
//

import Foundation

final class NotEmptyValidation<T: Equatable>: Validatable {
    
    private let fieldName: String
    var error: ValidateError?
    
    init(fieldName: String, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.error = error
    }
    
    func validate(data: [String : Any]?) -> ValidateError? {
        guard let value = data?[fieldName] as? [T] else { return error }
        return nil
    }
    
    func validate(value: [T]) -> ValidateError? {
        return value.isEmpty ? error : nil
    }
    
}
