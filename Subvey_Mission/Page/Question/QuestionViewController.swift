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
    
    private let viewModel: QuestionViewModel
    private let questionView: QuestionView
    
    init(formManager: FormManager, viewModel: QuestionViewModel) {
        self.formManager = formManager
        self.viewModel = viewModel
        self.questionView = QuestionView(form: viewModel.getCurrentForm()!)
        super.init(nibName: nil, bundle: nil)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(questionView)
        questionView.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func bind() {
        viewModel.formViewUpdateHandler = { [weak self] form in
            DispatchQueue.main.async {
                let answer = self?.questionView.next(nextForm: form)
                self?.viewModel.updateAnswer(answer: answer)
            }
        }
        
        questionView.onNextButtonTap = { [weak self] in
            self?.viewModel.fetchNextQuestion()
        }
    }

}
