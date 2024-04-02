## Validation 기능 구현
[라이브러리](https://github.com/adamwaite/Validator/blob/master/Validator/Sources/Rules/ValidationRule.swift)를 참고하여 기능 구현     
Validation이 가능한 프로토콜을 구현하고 채택한 클래스마다 상황에 맞게 validate를 구현    
```swift
protocol Validatable {
    associatedtype InputType
    var error: ValidateError? { get set }
    func validate(value: InputType) -> ValidateError?
}
```
```swift
final class ConfirmValidation<T: Equatable>: Validatable {
        
    private let fieldName: String
    private let compareValue: T
    var error: ValidateError?
    
    init(fieldName: String, compareValue: T, error: ValidateError? = ValidateError(message: "조건에 맞지 않습니다.")) {
        self.fieldName = fieldName
        self.compareValue = compareValue
        self.error = error
    }

// 설문을 서버에 보내기 전에 하는 유효성 검사
// 유효성 검사를 통과한 경우 다음 설문을 서버로부터 받아야하기 때문에 필요함
    func validate(data: [String : Any]?) -> ValidateError? {
        guard let value = data?[fieldName] as? T,
              value == compareValue else { return error }
        return nil
    }

// 일반적인 유효성 검사
    func validate(value: T) -> ValidateError? {
        return value == compareValue ? nil : error
    }
}
```

만약 한번에 여러개의 유효성 검사를 하려면 FormValidator를 통해서 할 수 있도록 구현함    
```swift
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
```

## 사용법
하나의 유효성 검사의 경우
```swift
ConfirmValidation(fieldName: validate.name, compareValue: compareValue).validate(value: input) // nil 일 경우 유효성 검사 통과 아닐경우 error 반환
```

여러개일 경우엔 FormValidator를 사용하여 실행할 수 있다.   
```swift
var validator: FormValidator<Int> = FormValidator<Int>()
formValidator.add(validate: ConfirmValidation(fieldName: name, compareValue: eqaulValue))
formValidator.add(validate: NotEqualValidation(fieldName: name, notCompareValue: notCompareValue))
formValidator.validate(input: input) // nil 일 경우 유효성 검사 통과 아닐경우 error 반환
```

