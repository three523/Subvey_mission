//
//  RadioFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioFormView: UIStackView, FormRenderable {

    var form: Form
    var type: FormType = .radio
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private var radioViews: [RadioView] = []

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
        let answer = getAnswer()
        
        questionLabel.text = form.question
        switch nextForm.placeholder {
        case .dictionary(let options):
            updateRadioViews(options: options)
        default: break
        }
        return answer
    }
    
    func updateRadioViews(options: [MultiValue.Option]) {
        if options.count > radioViews.count {
            addRadioViews(count: options.count - radioViews.count)
        } else if options.count < radioViews.count {
            removeRadioViews(count: radioViews.count - options.count)
        }
        
        for index in 0..<options.count {
            let option = options[index]
            DispatchQueue.main.async { [weak self] in
                self?.radioViews[index].answerLabel.text = option.label
                self?.radioViews[index].radioButton.isSelected = option.checked
                self?.radioViews[index].value = option.value
            }
        }
    }
    
    private func addRadioViews(count: Int) {
        for _ in 0..<count {
            let radioInputView = RadioView()
            radioViews.append(radioInputView)
            addArrangedSubview(radioInputView)
        }
    }
    
    private func removeRadioViews(count: Int) {
        for _ in 0..<count {
            if let radioInputView = radioViews.popLast() {
                radioInputView.removeArrangedSubview(radioInputView)
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        let name = form.name
        var value: String?
        for radioView in radioViews {
            if radioView.radioButton.isSelected {
                value = radioView.value
            }
        }
        guard let value else { return nil }
        return [name: value]
    }
}

//MARK: Setup
private extension RadioFormView {
    func setup() {
        setupInit()
        setupSubViews()
    }
    
    func setupInit() {
        axis = .vertical
        spacing = 20
    }
    
    func setupSubViews() {
        addArrangedSubview(questionLabel)
    }
    
    func setupForm() {
        switch form.placeholder {
        case .dictionary(let options):
            updateRadioViews(options: options)
        default: break
        }
    }
}
