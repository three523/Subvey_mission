//
//  QuestionViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/01/31.
//

import UIKit
import SnapKit

class QuestionViewController: UIViewController {
    
    let forms: [Form]
    let currentIndex: Int
    
    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.textColor = .black
        return field
    }()
    private let btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("next", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    init(currentIndex: Int, forms: [Form]) {
        self.currentIndex = currentIndex
        self.forms = forms
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        view.addSubview(btn)
        
        textField.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.right.equalToSuperview().inset(16)

        }
        btn.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.centerX.equalTo(textField.snp.centerX)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        if currentIndex == -1 {
            textField.isEnabled = false
            textField.text = "설문조사가 완료되었습니다."
            textField.textAlignment = .center
            btn.setTitle("완료", for: .normal)
            btn.addTarget(self, action: #selector(doneQuestion), for: .touchUpInside)
        } else {
            btn.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
            switch forms[currentIndex].placeholder {
            case .string(let placeholder):
                textField.placeholder = placeholder
            case .int(_):
                break
            case .bool(_):
                break
            }
        }
    }
    
    @objc func nextQuestion() {
        let nextIndex = currentIndex + 1
        if forms.count > nextIndex {
            let vc = QuestionViewController(currentIndex: currentIndex + 1, forms: forms)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = QuestionViewController(currentIndex: -1, forms: forms)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func doneQuestion() {        
        let apiHandler = APIHandler()
        apiHandler.fetchQuestion(type: Answer.self, apiType: .answer, typeID: "common") { [weak self] answer in
            let nextTypeID = answer.data.nextTypeId
            apiHandler.fetchQuestion(type: Question.self, apiType: .question, typeID: nextTypeID) { [weak self] question in
                let forms = question.data.forms
                let vc = QuestionViewController(currentIndex: 0, forms: forms)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
