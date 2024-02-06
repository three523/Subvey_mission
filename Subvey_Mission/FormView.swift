//
//  FormView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/06.
//

import UIKit
import SnapKit

class FormView: UIView, Animatable {
    
    enum state {
        case next
        case done
        case other
    }
    
    enum formType {
        case text
        case select
        case multiSelect
    }
    
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
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
    
    var nextForm: Form? = nil
    
    init(views:[UIView], type: formType) {
        super.init(frame: .zero)
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func next(nextForm: Form) {
        
        self.layer.removeAnimation(forKey: "move")
        self.layer.removeAnimation(forKey: "fade")
        
        let moveLayer = stackView.layer
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
        
        let animations = [moveAnimation, fadeAnimation]
        
        self.layer.add(moveAnimation, forKey: "move")
        self.layer.add(fadeAnimation, forKey: "fade")
    }
    
    func nextQuestion() {
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
        
        self.layer.add(moveAnimation, forKey: "next")
        self.layer.add(fadeAnimation, forKey: "nextFade")
    }
}

extension FormView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.layer.removeAnimation(forKey: "next")
            self.layer.removeAnimation(forKey: "nextFade")
            nextQuestion()
        }
    }
}

extension FormView {
    func addFormView(views: [UIView]) {
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
    }
}
private extension FormView {
    func setAutoLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(inset)
        }
    }
}
