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
        handler.fetchQuestion(type: Question.self, apiType: .question, typeID: "common") { [weak self] question in
            let forms = question.data.forms
            DispatchQueue.main.async {
                self?.navigationController?.pushViewController(QuestionViewController(currentIndex: 0, forms: forms), animated: true)
            }
        }
    }

}

class FormManager {
    var nextForm: Form?
    var currentForm: Form
    
    init(nextForm: Form? = nil, currentForm: Form) {
        self.nextForm = nextForm
        self.currentForm = currentForm
    }
}
