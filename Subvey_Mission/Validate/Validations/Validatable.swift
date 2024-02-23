//
//  Validator.swift
//  InputManager
//
//  Created by 김도현 on 2024/01/07.
//

import Foundation

protocol Validatable {
    associatedtype InputType
    var error: ValidateError { get set }
    func validate(value: InputType) -> ValidateError?
}
