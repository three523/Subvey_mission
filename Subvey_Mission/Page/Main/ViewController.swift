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
        handler.fetchSubvey(typeID: "common") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let subvey):
                let formManager = FormManager(forms: subvey.data.forms)
                let viewModel = QuestionViewModel(formManager: formManager, apiHandler: APIHandler())
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(QuestionViewController(formManager: formManager, viewModel: viewModel), animated: true)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
                //TODO: 첫 설문 실패시 에러 처리
            }
        }
    }

}
