//
//  NumberFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/08.
//

import UIKit

final class NumberFormView: ErrorHandlerView, FormReRenderView {
    var type: FormType
    var form: Form
    var validator: FormValidator<Int>? = nil
    var answer: Any?
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private lazy var answerTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.delegate = self
        return textField
    }()
    private lazy var defaultError: ValidateError = ValidateError(message: "숫자를 입력해야 합니다") {
        self.errorLabel.text = "숫자를 입력해야합니다."
        self.errorLabel.isHidden = false
    }

    init(form: Form, answer: Any? = nil) {
        self.type = .text
        self.form = form
        self.answer = answer
        super.init(frame: .zero)
        if let answer = answer as? Int {
            answerTextField.text = String(answer)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form, answer: Any? = nil) {
        self.form = nextForm
        DispatchQueue.main.async {
            self.questionLabel.text = nextForm.question
            if let answer = answer as? Int {
                self.answerTextField.text = String(answer)
            } else {
                switch nextForm.placeholder {
                case .int(let number):
                    self.answerTextField.placeholder = String(number)
                default: break
                }
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        let name = form.name
        guard let text = answerTextField.text,
              let number = Int(text) else { return nil }
        answer = number
        resetTextField()
        return [name: number]
    }
    
    func validate() -> ValidateError? {
        guard let text = answerTextField.text else { return defaultError }
        if text.isEmpty {
            if form.required {
                return defaultError
            } else {
                return nil
            }
        }
        guard let number = Int(text) else { return defaultError }
        return validator?.validate(input: number)
    }
    
    func createValidator() {
        let formValidator = FormValidator<Int>()
        form.validate.forEach { validate in
            let error = ValidateError(message: validate.validateText) {
                self.errorLabel.text = validate.validateText
                self.isError = true
            }
            if validate.type == "not" {
                switch validate.target {
                case .int(let compareValue):
                    let notEqualValidate = NotEqualValidation(fieldName: form.name, compareValue: compareValue, error: error)
                    formValidator.add(validate: notEqualValidate)
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "minMaxLength" {
                switch validate.target {
                case .minMax(let minMax):
                    if let minValue = minMax.first {
                        switch minValue {
                        case .int(let min):
                            let minValidate = MinValidation(fieldName: form.name, minLength: min, error: error)
                            formValidator.add(validate: minValidate)
                        case .string(_): break
                        }
                    }
                    if let maxValue = minMax.last {
                        switch maxValue {
                        case .int(let max):
                            let maxValidation = MaxValidation(fieldName: form.name, maxLength: max, error: error)
                            formValidator.add(validate: maxValidation)
                        case .string(_): break
                        }
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "sameAS" {
                switch validate.target {
                case .int(let eqaulValue):
                    let equalValidate = ConfirmValidation(fieldName: form.name, compareValue: eqaulValue, error: error)
                    formValidator.add(validate: equalValidate)
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
    
    override func setup() {
        super.setup()
        setupForm()
    }
    
    override func setupSubViews() {
        addArrangedSubview(questionLabel)
        addArrangedSubview(answerTextField)
        addArrangedSubview(errorLabel)
        super.setupSubViews()
    }
    
    func setupForm() {
        questionLabel.text = form.question
        
        if let answer = answer as? Int {
            answerTextField.text = String(answer)
        } else {
            switch form.placeholder {
            case .int(let number):
                answerTextField.placeholder = String(number)
            default: break
            }
        }
    }
}

extension NumberFormView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        isError = false
    }
}
