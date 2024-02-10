//
//  RadioWithInputView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioWithInputView: UIStackView, FormCheckable {
    
    var radioView: RadioView = RadioView()
    var otherTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.borderStyle = .line
        return textField
    }()
    
    var value: String?
    var radioUpdateHandler: ((String) -> Void)? {
        didSet {
            radioView.radioUpdateHandler = radioUpdateHandler
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUi(option: MultiValue.Option) {
        radioView.answerLabel.text = option.label
        radioView.radioButton.isSelected = option.checked
        radioView.value = option.value
        value = option.value
    }
    
    func getAnswer() -> [String : Any]? {
        guard let value,
              let text = otherTextField.text else { return nil }
        return radioView.radioButton.isSelected ? [value: text] : nil
    }
    
    func updateSelected(isSelected: Bool) {
        radioView.radioButton.isSelected = isSelected
        otherTextField.isEnabled = isSelected
        otherTextField.backgroundColor = isSelected ? .white : .systemGray4
    }
    
    func isRadioSelected() -> Bool {
        return radioView.isRadioSelected()
    }
}

private extension RadioWithInputView {
    func setup() {
        setupInit()
        setupSubViews()
        setupRadioView()
    }
    
    func setupInit() {
        axis = .vertical
        alignment = .fill
        distribution = .fill
    }
    
    func setupSubViews() {
        addArrangedSubview(radioView)
        addArrangedSubview(otherTextField)
    }
    
    func setupRadioView() {
        radioView.radioInputUpdateHandler = { [weak self] in
            self?.otherTextField.isEnabled = true
            self?.otherTextField.backgroundColor = .clear
        }
    }
}

