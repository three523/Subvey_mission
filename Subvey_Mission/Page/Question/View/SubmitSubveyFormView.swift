//
//  SubmitSubveyFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/10.
//

import UIKit

final class SubmitSubveyFormView: UIStackView, FormReRenderView {
    var type: FormType
    var form: Form
    var answer: Any?
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()

    init(form: Form, frame: CGRect = .zero, answer: Any? = nil) {
        self.type = form.type
        self.form = form
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form, answer: Any? = nil) {}
    
    func getAnswer() -> [String : Any]? {
        return nil
    }
    
    func validate() -> ValidateError? {
        return nil
    }
    
    func createValidator() {
        
    }
}

private extension SubmitSubveyFormView {
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
    }
    
    func setupForm() {
        questionLabel.text = "설문조사에 참여해주셔서 감사합니다."
    }
}
