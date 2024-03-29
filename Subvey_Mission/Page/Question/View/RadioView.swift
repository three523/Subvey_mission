//
//  RadioInputView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioView: UIStackView, FormCheckable {

    let radioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "circle.fill"), for: .selected)
        return button
    }()
    
    let answerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    var radioButtonSize: CGFloat = 30 {
        didSet {
            radioButton.snp.updateConstraints { make in
                make.width.height.equalTo(radioButtonSize)
            }
        }
    }
    
    var defaultSpaing: CGFloat = 16 {
        didSet {
            spacing = defaultSpaing
        }
    }
    
    var value: String? = nil
    var radioUpdateHandler: ((String) -> Void)?
    var radioInputUpdateHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUi(option: MultiValue.Option) {
        radioButton.isSelected = option.checked
        answerLabel.text = option.label
        value = option.value
    }
    
    func getAnswer() -> [String : Any]? {
        guard let value else { return nil }
        return radioButton.isSelected ? [value: true] : nil
    }
    
    func updateSelected(isSelected: Bool) {
        radioButton.isSelected = isSelected
    }
    
    func isRadioSelected() -> Bool {
        return radioButton.isSelected
    }
}

private extension RadioView {
    func setup() {
        setupInit()
        setupSubViews()
        setupAutoLayout()
        setupButton()
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
    
    func setupAutoLayout() {
        radioButton.snp.makeConstraints { make in
            make.width.height.equalTo(radioButtonSize)
        }
    }
    
    func setupButton() {
        radioButton.addTarget(self, action: #selector(radioButtonClick), for: .touchUpInside)
    }
    
    @objc func radioButtonClick() {
        radioButton.isSelected = true
        guard let value else { return }
        radioUpdateHandler?(value)
        radioInputUpdateHandler?()
    }
}
