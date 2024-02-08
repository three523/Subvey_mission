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

    init(form: Form) {
        self.type = .text
        self.form = form
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form) -> [String : Any]? {
        let answer = Int(answerTextField.text ?? "-1") ?? -1
        let name = form.name
        
        DispatchQueue.main.async {
            self.questionLabel.text = nextForm.question
            switch nextForm.placeholder {
            case .string(let placeholder):
                self.answerTextField.placeholder = placeholder
            default: break
            }
        }
        
        return [name: answer]
    }
    
    func getAnswer() -> [String : Any]? {
        var answer: Int = Int(self.answerTextField.text ?? "-1") ?? -1
        let name = form.name
        return [name: answer]
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
        
        switch form.placeholder {
        case .string(let placeholder):
            answerTextField.placeholder = placeholder
        default: break
        }
    }
}
