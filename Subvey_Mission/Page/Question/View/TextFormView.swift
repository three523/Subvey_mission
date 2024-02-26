//
//  TextFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

final class TextFormView: UIStackView, FormRenderable {
    var type: FormType
    var form: Form
    var answer: Any?
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private let answerTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.text = ""
        return textField
    }()
    
    var validator: FormValidator<String>? = nil

    init(form: Form, answer: Any? = nil) {
        self.type = .text
        self.form = form
        super.init(frame: .zero)
        
        if let answer = answer as? String {
            answerTextField.text = answer
        }
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form, answer: Any? = nil){
        self.form = nextForm
        
        if let answer = answer as? String {
            answerTextField.text = answer
        }
        DispatchQueue.main.async {
            self.questionLabel.text = nextForm.question
            switch nextForm.placeholder {
            case .string(let placeholder):
                self.answerTextField.placeholder = placeholder
            default: break
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        let answer = answerTextField.text ?? ""
        let name = form.name
        
        resetTextField()
        
        return [name: answer]
    }
    
    func validate() -> ValidateError? {
        return validator?.validate(input: answerTextField.text ?? "")
    }
    
    func createValidator() {
        let formValidator = FormValidator<String>()
        form.validate.forEach { validate in
            let error = ValidateError(message: validate.validateText)
            if validate.type == "not" {
                switch validate.target {
                case .string(let compareValue):
                    let notEqualValidate = NotEqualValidation(fieldName: form.name, compareValue: compareValue, error: error)
                    formValidator.add(validate: notEqualValidate)
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "minMaxLength" {
                var minLength = 0
                var maxLength = 0
                
                switch validate.target {
                case .minMax(let minMax):
                    if let minValue = minMax.first {
                        switch minValue {
                        case .int(let min):
                            minLength = min
                        case .string(_): break
                        }
                    }
                    if let maxValue = minMax.last {
                        switch maxValue {
                        case .int(let max):
                              maxLength = max
                        case .string(_): break
                        }
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
                let minMaxLengthValidate = MinMaxLengthValidation(fieldName: form.name, minLength: minLength, maxLength: maxLength, error: error)
                formValidator.add(validate: minMaxLengthValidate)
            } else if validate.type == "sameAS" {
                switch validate.target {
                case .string(let eqaulValue):
                    let equalValidate = ConfirmValidation(fieldName: form.name, compareValue: eqaulValue, error: error)
                    formValidator.add(validate: equalValidate)
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
        }
        self.validator = formValidator
    }
    
    private func resetTextField() {
        answerTextField.text = ""
        answerTextField.resignFirstResponder()
    }
}

private extension TextFormView {
    func setup() {
        setupInit()
        setupSubViews()
        setupForm()
    }
    
    func setupInit() {
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
    }
    
    func setupSubViews() {
        addArrangedSubview(questionLabel)
        addArrangedSubview(answerTextField)
    }
    
    func setupForm() {
        questionLabel.text = form.question
        
        switch form.placeholder {
        case .string(let placeholder):
            answerTextField.placeholder = placeholder
        default: break
        }
    }
}
