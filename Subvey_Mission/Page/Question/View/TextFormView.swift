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
        return textField
    }()

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
        return nil
    }
    
    func createValidator() {
        
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
