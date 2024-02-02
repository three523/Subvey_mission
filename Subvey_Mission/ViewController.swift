//
//  ViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/01/30.
//

import UIKit

class ViewController: UIViewController {
    
    var formManager: FormManager = FormManager(forms: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let handler = APIHandler()
        handler.fetchQuestion(type: Question.self, apiType: .question, typeID: formManager.typeId) { [weak self] question in
            guard let self else { return }
            let forms = question.data.forms
            self.formManager.forms = forms
            self.formManager.currentIndex = forms.isEmpty ? nil : 0
            DispatchQueue.main.async {
//                self?.navigationController?.pushViewController(QuestionViewController(currentIndex: 0, forms: forms), animated: true)
                self.navigationController?.pushViewController(QuestionViewController(formManager: self.formManager), animated: true)
            }
        }
    }

}

final class FormManager {
    var forms: [Form]
    var typeId: String = "common"
    var currentIndex: Int?
    var answers: [String: Any] = [:]
    
    init(forms: [Form]) {
        self.forms = forms
    }
    
    func getCurrentForm() -> Form? {
        guard let currentIndex else { return nil }
        return forms[currentIndex]
    }
    
    func updateValue(question: String, answer: Any) {
        answers[question] = answer
    }
    
    func nextQuestion() {
        guard let currentIndex, currentIndex + 1 < forms.count else {
            self.currentIndex = nil
            return
        }
        self.currentIndex = currentIndex + 1
    }
}
