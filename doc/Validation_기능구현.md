## Validation 기능 구현
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
