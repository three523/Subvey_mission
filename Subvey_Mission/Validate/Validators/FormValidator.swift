//
//  FormValidator.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/22.
//

final class FormValidator<InputType> {
    var validations: [AnyValidation<InputType>] = []
    
    init() {
        
    }
    
    init<V: Validatable>(validations: [V] = []) where V.InputType == InputType {
        self.validations = validations.map{ AnyValidation(base: $0) }
    }
    
    func add<V: Validatable>(validate: V) where V.InputType == InputType {
        let anyValidate = AnyValidation(base: validate)
        validations.append(anyValidate)
    }
    
    func validate(input: InputType) -> ValidateError? {
        for validation in validations {
            if let error = validation.validate(input: input) {
                return error
            }
        }
        return nil
    }
}


struct AnyValidation<InputType> {
    let error: ValidateError?
    
    private let baseValidateInput: (InputType) -> ValidateError?
    
    init<V: Validatable>(base: V) where V.InputType == InputType {
        baseValidateInput = base.validate
        error = base.error
    }
    
    func validate(input: InputType) -> ValidateError? {
        return baseValidateInput(input)
    }
}
