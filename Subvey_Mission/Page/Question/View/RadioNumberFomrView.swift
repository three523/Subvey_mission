//
//  RadioNumberFomrView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/10.
//

import UIKit

final class RadioNumberFormView: UIStackView, FormRenderable {
    var type: FormType
    var form: Form
    
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

    init(form: Form) {
        self.type = .text
        self.form = form
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form){
        DispatchQueue.main.async {
            self.questionLabel.text = nextForm.question
            switch nextForm.placeholder {
            case .int(let number):
                self.slider.setValue(Float(number), animated: false)
            default: break
            }
        }
    }
    
    func getAnswer() -> [String : Any]? {
        let answer = String(Int(slider.value))
        let name = form.name
                
        return [name: answer]
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
        
        switch form.placeholder {
        case .int(let number):
            slider.setValue(Float(number), animated: false)
            answerLabel.text = String(Int(number))
        default: break
        }
    }
    
    @objc func updateSlider(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        
        sender.setValue(roundedValue, animated: false)
        answerLabel.text = String(Int(roundedValue))
    }
}
