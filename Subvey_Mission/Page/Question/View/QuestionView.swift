//
//  FormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/06.
//

import UIKit
import SnapKit

final class QuestionView: UIView {
    
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("next", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        return btn
    }()
    
    var onNextButtonTap: (() -> Void)?
    var subveyCompleteHandler: (() -> Void)?
    
    var inset: CGFloat = 16 {
        didSet {
            stackView.snp.updateConstraints { make in
                make.edges.equalToSuperview().inset(inset)
            }
        }
    }
    var spacing: CGFloat = 16 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    typealias FormView = (UIView & FormRenderable)
    
    var currentView: FormView? = nil
    var nextForm: Form? = nil
    
    init(form: Form, frame: CGRect = .zero) {
        super.init(frame: frame)
        setup(form: form)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func nextQuestion() {
        if currentView is SubmitSubveyFormView {
            subveyCompleteHandler?()
        } else {
            onNextButtonTap?()
        }
    }
    
    func next(nextForm: Form?) -> [String: Any]? {
        if let nextForm = nextForm {
            let answer = currentView?.getAnswer()
            self.nextForm = nextForm
            fadeOut()
            return answer
        } else {
            let answer = currentView?.getAnswer()
            self.nextForm = nil
            fadeOut()
            return answer
        }
    }
    
    private func updateCurrentView(nextForm: Form?) {
        guard let nextForm else {
            guard let form = currentView?.form else { return }
            let submitFormView = SubmitSubveyFormView(form: form)
            replaceCurrentView(submitView: submitFormView)
            return
        }
        if shouldReuseView(form: nextForm) {
            currentView?.next(nextForm: nextForm)
        } else {
            let newView = createView(nextForm: nextForm)
            replaceCurrentView(formView: newView)
        }
    }
    
    func shouldReuseView(form: Form) -> Bool {
        guard let currentView else { return false }
        return viewType(type: form.type) == type(of: currentView)
    }
    
    private func viewType(type: FormType) -> UIView.Type {
        switch type {
        case .text:
            return TextFormView.self
        case .radio:
            return RadioFormView.self
        case .radioWithInput:
            return RadioWithInputFormView.self
        case .number:
            return NumberFormView.self
        case .radioNumber:
            return RadioNumberFormView.self
        case .checkbox:
            //TODO: CheckBoxFormView 만들기
            return NumberFormView.self
        }
    }
    
    private func createView(nextForm: Form) -> FormView {
        let nextFormType = nextForm.type
        switch nextFormType {
        case .text:
            return TextFormView(form: nextForm)
        case .radio:
            return RadioFormView(form: nextForm)
        case .radioWithInput:
            return RadioWithInputFormView(form: nextForm)
        case .number:
            return NumberFormView(form: nextForm)
        case .radioNumber:
            return RadioNumberFormView(form: nextForm)
        case .checkbox:
            return TextFormView(form: nextForm)
        }
    }
    
    private func replaceCurrentView(formView: FormView) {
        guard let currentView else { return }
        if currentView is SubmitSubveyFormView { btn.setTitle("next", for: .normal) }
        currentView.removeFromSuperview()

        self.stackView.insertArrangedSubview(formView, at: 0)
        
        self.currentView = formView
    }
    
    private func replaceCurrentView(submitView: SubmitSubveyFormView) {
        guard let currentView else { return }
        btn.setTitle("제출", for: .normal)
        currentView.removeFromSuperview()
        
        stackView.insertArrangedSubview(submitView, at: 0)
        self.currentView = submitView
    }
}

//MARK: Animation
extension QuestionView: CAAnimationDelegate {
    
    private func fadeOut() {
        
        self.layer.removeAnimation(forKey: "fadeout-move")
        self.layer.removeAnimation(forKey: "fadeout-opacity")
        
        let moveAnimation = CABasicAnimation(keyPath: "position")

        moveAnimation.byValue = NSValue(cgPoint: CGPoint(x: -100, y: 0))
        moveAnimation.duration = 0.5
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.delegate = self
                
        self.layer.add(moveAnimation, forKey: "fadeout-move")
        self.layer.add(fadeAnimation, forKey: "fadeout-opacity")
    }
    
    private func fadeIn() {
        
        self.layer.removeAnimation(forKey: "fadein-move")
        self.layer.removeAnimation(forKey: "fadein-opacity")
        
        let moveAnimation = CABasicAnimation(keyPath: "position")
        let center = center
        
        moveAnimation.fromValue = NSValue(cgPoint: CGPoint(x: center.x + 100, y: center.y))
        moveAnimation.toValue = NSValue(cgPoint: center)
        moveAnimation.duration = 0.5
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = 0.5
        
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        self.layer.add(moveAnimation, forKey: "fadein-move")
        self.layer.add(fadeAnimation, forKey: "fadein-opacity")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let nextForm {
            updateCurrentView(nextForm: nextForm)
        } else {
            updateCurrentView(nextForm: nil)
        }
        fadeIn()
    }
}

//MARK: Setup
private extension QuestionView {
    
    func setup(form: Form) {
        setupSubViews()
        setupAutoLayout()
        setupForm(form: form)
    }
    
    func setupSubViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(btn)
    }
    
    func setupAutoLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(inset)
        }
    }
    
    func setupForm(form: Form) {
        currentView = createView(nextForm: form)
        
        guard let currentView = currentView else { return }
        stackView.insertArrangedSubview(currentView, at: 0)
    }
}
