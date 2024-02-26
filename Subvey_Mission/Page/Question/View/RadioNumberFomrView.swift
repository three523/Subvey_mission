//
//  RadioNumberFomrView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/10.
//

import UIKit

enum ValidateType: String {
    case not
    case minMax
    case sameAS
    case pattern
    case minMaxLength
}

final class RadioNumberFormView: UIStackView, FormRenderable {
    var type: FormType
    var form: Form
    var answer: Any?
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 7
        slider.minimumValue = 1
        slider.addTarget(self, action: #selector(updateSlider), for: .valueChanged)
        return slider
    }()
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    var validator: FormValidator<Int>? = nil

    init(form: Form, answer: Any? = nil) {
        self.type = .text
        self.form = form
        self.answer = answer
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form, answer: Any? = nil) {
        self.form = nextForm
        DispatchQueue.main.async {
            self.questionLabel.text = nextForm.question
            if let answer = answer as? Int {
                self.slider.setValue(Float(answer), animated: false)
                self.answerLabel.text = String(answer)
            } else {
                switch nextForm.placeholder {
                case .int(let number):
                    self.slider.setValue(Float(number), animated: false)
                    self.answerLabel.text = String(number)
                default: break
                }
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        if let text = answerLabel.text,
           text == "0" {
            return nil
        }
              
        let answer = Int(slider.value)
        let name = form.name
        return [name: answer]
    }
    
    func validate() -> ValidateError? {
        return validator?.validate(input: Int(slider.value))
    }
    
    func createValidator() {
        let formValidator = FormValidator<Int>()
        form.validate.forEach { validate in
            let error = ValidateError(message: validate.validateText)
            if validate.type == "not" {
                switch validate.target {
                case .int(let compareValue):
                    let notEqualValidate = NotEqualValidation(fieldName: form.name, compareValue: compareValue, error: error)
                    formValidator.add(validate: notEqualValidate)
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "minMax" {
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
                            let maxValidate = MaxValidation(fieldName: form.name, maxLength: max, error: error)
                            formValidator.add(validate: maxValidate)
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
}

private extension RadioNumberFormView {
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
        addArrangedSubview(slider)
        addArrangedSubview(answerLabel)
    }
    
    func setupForm() {
        questionLabel.text = form.question
        
        if let answer = answer as? Int {
            self.slider.setValue(Float(answer), animated: false)
            answerLabel.text = String(Int(answer))
        } else {
            switch form.placeholder {
            case .int(let number):
                slider.setValue(Float(number), animated: false)
                answerLabel.text = String(Int(number))
            default: break
            }
        }
    }
    
    @objc func updateSlider(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        
        sender.setValue(roundedValue, animated: false)
        answerLabel.text = String(Int(roundedValue))
    }
}
