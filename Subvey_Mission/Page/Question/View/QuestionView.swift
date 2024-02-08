//
//  FormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/06.
//

import UIKit
import SnapKit

final class QuestionView: UIView {
    
    enum state {
        case next
        case done
        case other
    }
    
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
    
    var currentView: UIView? = nil
    var nextForm: Form? = nil
    
    init(form: Form, frame: CGRect = .zero) {
        super.init(frame: frame)
        setup(form: form)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func next() {
        fadeOut()
    }
    
    @objc func nextQuestion() {
        onNextButtonTap?()
//        formManager.nextQuestion()
//        if let nextForm = formManager.getCurrentForm() {
//            next(nextForm: nextForm)
//        } else {
//
//        }
//        fadeOut()
    }
    
//    func next(nextForm: Form) -> [String: Any]? {
//        let answer = (currentView as? FormRenderable)?.getAnswer()
//        if let answer = (currentView as? FormRenderable)?.getAnswer() {
//            formManager.answers.merge(answer, uniquingKeysWith: { (oldValue, newValue) in newValue })
//        }
//        updateCurrentView(nextForm: nextForm)
//
//        return answer
//    }
    
    func next(nextForm: Form?) -> [String: Any]? {
        if let nextForm {
            let answer = (currentView as? FormRenderable)?.getAnswer()
            fadeOut()
            self.nextForm = nextForm
            return answer
        } else {
            //TODO: 설문에 참여해주셔서 감사합니다라는 텍스트와 함께 완료 버튼 생성 구현
            fadeOut()
            return nil
        }
    }
    
    private func updateCurrentView(nextForm: Form) {
        if shouldReuseView(form: nextForm) {
            (self.currentView as? FormRenderable)?.next(nextForm: nextForm)
        } else {
            let newView = createView(nextForm: nextForm)
            replaceCurrentView(with: newView)
        }
    }
    
    func shouldReuseView(form: Form) -> Bool {
        guard let currentView else { return false }
        print(viewType(type: form.type), type(of: currentView))
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
            return NumberFormView.self
        default:
            return UIView.self
        }
    }
    
    private func createView(nextForm: Form) -> UIView {
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
            return NumberFormView(form: nextForm)
        default: return UIView()
        }
    }
    
    private func replaceCurrentView(with newView: UIView) {
        guard let currentView else { return }
        currentView.removeFromSuperview()

        stackView.insertArrangedSubview(newView, at: 0)
        self.currentView = newView
    }
}

extension QuestionView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if let nextForm {
                updateCurrentView(nextForm: nextForm)
            }
            fadeIn()
        }
    }
}

extension QuestionView {
    func addFormView(views: [UIView]) {
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
    }
}
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
        switch form.type {
        case .text:
            currentView = TextFormView(form: form)
        case .radio:
            currentView = RadioFormView(form: form)
        case .radioWithInput:
            currentView = RadioWithInputFormView(form: form)
        case .number:
            currentView = NumberFormView(form: form)
        default: break
        }
        
        guard let currentView = currentView else { return }
        stackView.insertArrangedSubview(currentView, at: 0)
    }
}
