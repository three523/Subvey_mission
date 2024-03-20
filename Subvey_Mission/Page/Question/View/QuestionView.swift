//
//  FormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/06.
//

import UIKit
import SnapKit

final class QuestionView: UIView {
    
    enum QuestionMove {
        case next
        case back
    }
    
    private let progressBar: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = 6
        return view
    }()
    
//    private var progressFillLayer: CGLayer?
    private var progressFillView: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .blue
        return view
    }()
    
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
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        return btn
    }()
    
    private var isAnimating: Bool = false
    
    var onNextButtonTap: (() -> Void)?
    var onBackButtonTap: (() -> Void)?
    var subveyCompleteHandler: (() -> Void)?
    
    private var move: QuestionMove = .next
    
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
    
    var currentView: FormView? = nil {
        didSet {
            if let currentView = currentView,
               !(currentView is SubmitSubveyFormView) {
                currentView.createValidator()
            }
        }
    }
    var nextForm: Form? = nil
    
    init(form: Form, frame: CGRect = .zero) {
        super.init(frame: frame)
        setup(form: form)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func nextQuestion() {
        if isAnimating { return }
        
        if let error = currentView?.validate() {
            print(error)
        } else {
            if currentView is SubmitSubveyFormView {
                subveyCompleteHandler?()
            } else {
                onNextButtonTap?()
            }
        }
    }
    
    @objc private func backQuestion() {
        if isAnimating { return }
        onBackButtonTap?()
    }
    
    func back(prevForm: Form?, answer: Any?) {
        updateCurrentView(nextForm: prevForm, answer: answer)
        move = .back
        fadeIn(move: move)
    }
    
    func next(nextForm: Form?) -> [String: Any]? {
        if let nextForm = nextForm {
            let answer = currentView?.getAnswer()
            self.nextForm = nextForm
            move = .next
            fadeOut(move: .next)
            return answer
        } else {
            let answer = currentView?.getAnswer()
            self.nextForm = nil
            move = .next
            fadeOut(move: .next)
            return answer
        }
    }
    
    private func updateCurrentView(nextForm: Form?, answer: Any? = nil) {
        guard let nextForm else {
            guard let form = currentView?.form else { return }
            let submitFormView = SubmitSubveyFormView(form: form)
            replaceCurrentView(submitView: submitFormView)
            return
        }
        if shouldReuseView(form: nextForm) {
            currentView?.next(nextForm: nextForm, answer: answer)
        } else {
            let newView = createView(nextForm: nextForm, answer: answer)
            replaceCurrentView(formView: newView)
        }
        currentView?.createValidator()
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
    
    private func createView(nextForm: Form, answer: Any? = nil) -> FormView {
        let nextFormType = nextForm.type
        switch nextFormType {
        case .text:
            return TextFormView(form: nextForm, answer: answer)
        case .radio:
            return RadioFormView(form: nextForm, answer: answer)
        case .radioWithInput:
            return RadioWithInputFormView(form: nextForm, answer: answer)
        case .number:
            return NumberFormView(form: nextForm, answer: answer)
        case .radioNumber:
            return RadioNumberFormView(form: nextForm, answer: answer)
        case .checkbox:
            return TextFormView(form: nextForm, answer: answer)
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
    
    private func fadeOut(move: QuestionMove) {
        
        isAnimating = true
        
        self.layer.removeAnimation(forKey: "fadeout-move")
        self.layer.removeAnimation(forKey: "fadeout-opacity")
        
        let moveAnimation = CABasicAnimation(keyPath: "position")

        moveAnimation.byValue = NSValue(cgPoint: CGPoint(x: move == .next ? -100 : 100, y: 0))
        moveAnimation.duration = 0.5
        
        let fadeAnimation = CABasicAnimation(keyPath: "fadeout-opacity")
        
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        
        fadeAnimation.setValue("fadeout", forKey: "name")
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.delegate = self
                
        self.layer.add(moveAnimation, forKey: "fadeout-move")
        self.layer.add(fadeAnimation, forKey: "fadeout-opacity")
    }
    
    private func fadeIn(move: QuestionMove) {
        
        isAnimating = true
        
        self.layer.removeAnimation(forKey: "fadein-move")
        self.layer.removeAnimation(forKey: "fadein-opacity")
        
        let moveAnimation = CABasicAnimation(keyPath: "position")
        let center = center
        
        let fromX = move == .next ? center.x + 100 : center.x - 100
        
        moveAnimation.fromValue = NSValue(cgPoint: CGPoint(x: fromX, y: center.y))
        moveAnimation.toValue = NSValue(cgPoint: center)
        moveAnimation.duration = 0.5
        
        let fadeAnimation = CABasicAnimation(keyPath: "fadein-opacity")
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = 0.5
        
        fadeAnimation.setValue("fadein", forKey: "name")
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.delegate = self
        
        self.layer.add(moveAnimation, forKey: "fadein-move")
        self.layer.add(fadeAnimation, forKey: "fadein-opacity")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let name = anim.value(forKey: "name") as? String,
           name == "fadein" {
            isAnimating = false
        } else if move == .next,
           let name = anim.value(forKey: "name") as? String,
           name == "fadeout" {
            if let nextForm {
                updateCurrentView(nextForm: nextForm)
            } else {
                updateCurrentView(nextForm: nil)
            }
            fadeIn(move: move)
        }
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
