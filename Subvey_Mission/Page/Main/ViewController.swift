//
//  ViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/01/30.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let handler = APIHandler()
        handler.fetchQuestion(type: Subvey.self, apiType: .question, typeID: "common") { [weak self] question in
            guard let self else { return }
            let forms = question.data.forms

            let formManager = FormManager(forms: forms)
            let viewModel = QuestionViewModel(formManager: formManager, apiHandler: APIHandler())

            DispatchQueue.main.async {
                self.navigationController?.pushViewController(QuestionViewController(formManager: formManager, viewModel: viewModel), animated: true)
            }
        }
    }

}

final class FormManager {
    var forms: [Form] {
        didSet {
            currentIndex = forms.isEmpty ? nil : 0
        }
    }
    var typeId: String = "common"
    var currentIndex: Int?
    var answers: [String: Any] = [:]
    
    init(forms: [Form]) {
        self.forms = forms
        currentIndex = forms.isEmpty ? nil : 0
    }
    
    func getCurrentForm() -> Form? {
        guard let currentIndex else { return nil }
        return forms[currentIndex]
    }
    
    func updateValue(question: String, answer: Any) {
        answers[question] = answer
    }
    
    func updateAnswer(answer: [String: Any]?) {
        guard let answer else { return }
        answers.merge(answer, uniquingKeysWith: { (oldValue, newValue) in newValue })
        
        //TODO: 로컬에 설문 내용 저장하는 기능 구현
    }
    
    func appendForms(newforms: [Form]) {
        forms.append(contentsOf: newforms)
    }
    
    func nextQuestion() -> Form? {
        guard let currentIndex, currentIndex + 1 < forms.count else {
            self.currentIndex = nil
            return nil
        }
        let nextIndex = currentIndex + 1
        self.currentIndex = nextIndex
        return forms[nextIndex]
    }
}
