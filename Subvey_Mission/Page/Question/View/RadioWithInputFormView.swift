//
//  RadioFormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

class RadioWithInputFormView: UIStackView, FormRenderable {

    var form: Form
    var type: FormType = .radioWithInput
    
    typealias FormRadioView = UIView & FormCheckable
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    private var radioViews: [FormRadioView] = []

    init(form: Form) {
        self.type = .text
        self.form = form
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form) {
        questionLabel.text = form.question
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
        var value: [String: Any]?
        for radioView in radioViews {
            if radioView.isRadioSelected() {
                value = radioView.getAnswer()
            }
        }
        guard let value else { return nil }
        return [name: value]
    }
    
    private func createRadioUpdateHandler() -> ((String) -> Void)? {
        return { [weak self] value in
            self?.radioViews.forEach { radioView in
                if radioView.value != value {
                    radioView.updateSelected(isSelected: false)
                }
            }
        }
    }
    
}

//MARK: Setup
private extension RadioWithInputFormView {
    func setup() {
        setupInit()
        setupSubViews()
        setupForm()
    }
    
    func setupInit() {
        axis = .vertical
        spacing = 20
    }
    
    func setupSubViews() {
        addArrangedSubview(questionLabel)
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
