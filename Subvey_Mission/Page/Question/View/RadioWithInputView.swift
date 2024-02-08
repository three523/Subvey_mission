//
//  RadioWithInputView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioWithInputView: RadioView {
    
    var otherTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.borderStyle = .line
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension RadioWithInputView {
    func setup() {
        setupInit()
        setupSubViews()
    }
    
    func setupInit() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
    }
    
    func setupSubViews() {
        addArrangedSubview(radioButton)
        addArrangedSubview(answerLabel)
    }
}

