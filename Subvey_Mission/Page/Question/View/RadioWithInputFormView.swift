//
//  RadioFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioWithInputFormView: ErrorHandlerView, FormReRenderView {

    var form: Form
    var type: FormType = .radioWithInput
    var answer: Any?
    
    typealias FormRadioView = UIView & FormCheckable
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private var radioViews: [FormRadioView] = []
    private var validator: FormValidator<[String]>? = nil
    private lazy var defaultValidateError: ValidateError = ValidateError(message: "필수로 입력해야합니다") {
        self.errorLabel.text = "필수로 입력해야 합니다."
        self.errorLabel.isHidden = false
    }

    init(form: Form, answer: Any? = nil) {
        self.type = .text
        self.form = form
        self.answer = answer
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form, answer: Any? = nil) {
        questionLabel.text = form.question
        self.form = nextForm
        switch nextForm.placeholder {
        case .dictionary(let options):
            updateRadioViews(options: options)
        default: break
        }
    }
    
    private func updateRadioViews(options: [MultiValue.Option]) {
        if options.count > radioViews.count {
            addRadioViews(count: options.count - radioViews.count)
        } else if options.count < radioViews.count {
            removeRadioViews(count: radioViews.count - options.count)
        }
        
        for index in 0..<options.count {
            let option = options[index]
            DispatchQueue.main.async { [weak self] in
                self?.radioViews[index].setupUi(option: option)
            }
        }
    }
    
    private func addRadioViews(count: Int) {
        //기존에 RadioInputView를 제거하고 RadioView를 전부 추가한 후에 마지막에 RadioInputView를 추가해 주기 위함
        removeLastRadioView()
        for _ in 0..<count {
            let radioInputView = RadioView()
            radioInputView.radioUpdateHandler = createRadioUpdateHandler()
            radioViews.append(radioInputView)
            addArrangedSubview(radioInputView)
        }
        addRadioInputView()
    }
    
    private func removeRadioViews(count: Int) {
        // 기타 radio 버튼을 마지막에 만들기 위해 count를 +1 해줌
        let count = count + 1
        for _ in 0..<count {
            if let radioInputView = radioViews.popLast() {
                removeArrangedSubview(radioInputView)
            }
        }
        addRadioInputView()
    }
    
    private func removeLastRadioView() {
        if let radioInputView = radioViews.popLast() {
            radioInputView.removeFromSuperview()
        }
    }
    
    private func addRadioInputView() {
        let radioWithInputView = RadioWithInputView()
        radioWithInputView.radioUpdateHandler = createRadioUpdateHandler()
        radioViews.append(radioWithInputView)
        addArrangedSubview(radioWithInputView)
    }
    
    func getAnswer() -> [String: Any]? {
        let name = form.name
        var values = [String]()
        for radioView in radioViews {
            if radioView.isRadioSelected() {
                if let value = radioView.value {
                    values.append(value)
                }
            }
        }
        return [name: values]
    }
    
    func validate() -> ValidateError? {
        let tempAnswer = getAnswer()
        answer = tempAnswer
        if form.required {
            guard let input = tempAnswer?[form.name] as? [String],
                  input.isEmpty == false else { return defaultValidateError }
            return validator?.validate(input: input)
        } else {
            if let input = tempAnswer?[form.name] as? [String] {
                return validator?.validate(input: input)
            }
        }
        return nil
    }
    
    func createValidator() {
        let formValidator = FormValidator<[String]>()
        form.validate.forEach { validate in
            let error = ValidateError(message: validate.validateText) {
                self.errorLabel.text = validate.validateText
                self.isError = true
            }
            if validate.type == "minMaxLength" {
                var minCount = 0
                var maxCount = 0
                
                switch validate.target {
                case .minMax(let minMax):
                    if let minValue = minMax.first {
                        switch minValue {
                        case .int(let min):
                            minCount = min
                        case .string(_): break
                        }
                    }
                    if let maxValue = minMax.last {
                        switch maxValue {
                        case .int(let max):
                              maxCount = max
                        case .string(_): break
                        }
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
                let minMaxLengthValidate = MinMaxArrayCountValidation<String>(fieldName: form.name, minCount: minCount, maxCount: maxCount, error: error)
                formValidator.add(validate: minMaxLengthValidate)
            } else if validate.type == "sameAS" {
                switch validate.target {
                case .stringArray(let eqaulValue):
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
    
    private func createRadioUpdateHandler() -> ((String) -> Void)? {
        return { [weak self] value in
            self?.isError = false
            self?.radioViews.forEach { radioView in
                if radioView.value != value {
                    radioView.updateSelected(isSelected: false)
                }
            }
        }
    }
    
    //MARK: Setup
    override func setup() {
        super.setup()
        setupForm()
    }
    
    override func setupInit() {
        axis = .vertical
        spacing = 20
    }
    
    func setupForm() {
        questionLabel.text = form.question
        switch form.placeholder {
        case .dictionary(let options):
            setupRadioView(options: options)
        default: break
        }
    }
    
    func setupRadioView(options: [MultiValue.Option]) {
        addRadioViews(count: options.count - 1)
        for index in 0..<options.count {
            let option = options[index]
            DispatchQueue.main.async { [weak self] in
                self?.radioViews[index].setupUi(option: option)
            }
        }
    }
}

