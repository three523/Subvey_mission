//
//  NumberFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/08.
//

import UIKit

final class NumberFormView: UIStackView, FormRenderable {
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
        return textField
    }()

    init(form: Form, answer: Any? = nil) {
        self.type = .text
        self.form = form
        self.answer = answer
        super.init(frame: .zero)
        if let answer = answer as? Int {
            answerTextField.text = String(answer)
        }
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
                self.answerTextField.text = String(answer)
            } else {
                switch nextForm.placeholder {
                case .int(let number):
                    self.answerTextField.text = String(number)
                default: break
                }
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        let answer: Int = Int(self.answerTextField.text ?? "-1") ?? -1
        let name = form.name
        
        resetTextField()
        return [name: answer]
    }
    
    func validate() -> ValidateError? {
        return nil
    }
    
    func createValidator() {
        
    }
    
    private func resetTextField() {
        answerTextField.text = "0"
        answerTextField.resignFirstResponder()
    }
}

private extension NumberFormView {
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
        
        if let answer = answer as? Int {
            answerTextField.text = String(answer)
        } else {
            switch form.placeholder {
            case .int(let number):
                answerTextField.text = String(number)
            default: break
            }
        }
    }
}
