//
//  QuestionTestViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/02.
//

import UIKit
import SnapKit

class QuestionViewController: UIViewController {

    let formManager: FormManager
    
    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.textColor = .black
        return field
    }()
    
    private let formView: FormView = FormView(views: [], type: .text)
    private let btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("next", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    init(formManager: FormManager) {
        self.formManager = formManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(formView)
        view.addSubview(btn)
        
//        textField.snp.makeConstraints { make in
//            make.center.equalTo(view.snp.center)
//            make.left.right.equalToSuperview().inset(16)
//
//        }
        formView.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.right.equalToSuperview().inset(16)
        }
        
        btn.snp.makeConstraints { make in
            make.top.equalTo(formView.snp.bottom).offset(10)
            make.centerX.equalTo(formView.snp.centerX)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        if let currentForm = formManager.getCurrentForm() {
            btn.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
            
            let questionView = UILabel()
            questionView.font = .systemFont(ofSize: 16, weight: .regular)
            questionView.text = currentForm.question
            formView.addFormView(views: [questionView, textField])
            
            switch currentForm.placeholder {
            case .string(let placeholder):
                textField.placeholder = placeholder
            case .int(_):
                break
            case .bool(_):
                break
            case .dictionary(_):
                break
            }
        } else {
            textField.isEnabled = false
            textField.text = "설문조사가 완료되었습니다."
            textField.textAlignment = .center
            btn.setTitle("완료", for: .normal)
            btn.addTarget(self, action: #selector(doneQuestion), for: .touchUpInside)
        }
    }
    
    @objc func nextQuestion() {
        guard let currentForm = formManager.getCurrentForm() else { return }
        var answer: Any
        switch currentForm.placeholder {
        case .string(let stringAnswer):
            answer = stringAnswer
        case .int(let intAnswer):
            answer = intAnswer
        case .bool(let boolAnswer):
            answer = boolAnswer
        case .dictionary(let dictionaryAnswers):
            var answers: [String: [String]] = [:]
            for dictionaryAnswer in dictionaryAnswers {
                if dictionaryAnswer.checked {
                    answers[dictionaryAnswer.label, default: []].append(dictionaryAnswer.value)
                }
            }
            answer = answers
        }
        formManager.updateValue(question: currentForm.question, answer: answer)
        formManager.nextQuestion()
        formView.animate()
//        let vc = QuestionViewController(formManager: formManager)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func doneQuestion() {
        let apiHandler = APIHandler()
        print(formManager.answers)
        apiHandler.fetchQuestion(type: Answer.self, apiType: .answer, typeID: formManager.typeId, sendData: formManager.answers) { [weak self] answer in
            guard let self else { return }
            if answer.data.nextTypeId == nil {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                return
            }
            self.formManager.typeId = answer.data.nextTypeId!
            apiHandler.fetchQuestion(type: Question.self, apiType: .question, typeID: self.formManager.typeId) { [weak self] question in
                guard let self else { return }
                let currentIndex = formManager.forms.count - 1
                self.formManager.currentIndex = currentIndex
                self.formManager.forms.append(contentsOf: question.data.forms)
                self.formManager.nextQuestion()
                if self.formManager.currentIndex != nil {
                    DispatchQueue.main.async {
                        let vc = QuestionViewController(formManager: self.formManager)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }

}
