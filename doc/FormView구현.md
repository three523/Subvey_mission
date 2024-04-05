## 구현
Json에는 Form 별로 여러개의 유효성 검사를 해줄 필요가 있다.    
예를 들면 이메일을 입력하는 설문 폼의 경우엔 이름이 비어있을 경우 체크와 2글자 이상인지 체크를 해줄 필요가 있다.    
각 Form에 맞는 View안에 Validation이 맞는지 체크하는 클래스를 배열로 만들어두고 다음 질문 버튼 클릭시 모든 유효성 검사를 실행하도록 구현    
아래는 예시코드
```swift
for validation in validations {
  if validate.type == "not" {
      switch validate.target {
      case .string(let compareValue):
          let notEqualValidate = NotEqualValidation(fieldName: form.name, compareValue: compareValue, error: error)
          formValidator.add(validate: notEqualValidate)
      default:
          print("잘못된 ValidateTarget 입니다.\(validate.target)")
          break
      }
  } else if validate.type == "pattern" {
      switch validate.target {
      case .string(let pattern):
          let patternValidate = CustomValidation(fieldName: form.name, pattern: pattern, error: error)
          formValidator.add(validate: patternValidate)
      default:
          print("잘못된 ValidateTarget 입니다.\(validate.target)")
          break
      }
  }
```
이런식으로 해야할 유효성 검사들을 모아놓고
```swift
formValidator.validate(input: answerTextField.text ?? "")
```
validate를 해주면 모든 유효성 검사를 진행하게 된다.
만약 nil이 반환 될경우 다음 질문으로 넘어가고    
아닐 경우 Validation에 들어가있는 error가 실행되도록 구현되어있다.
