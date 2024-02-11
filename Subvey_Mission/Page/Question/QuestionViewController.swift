//
//  QuestionTestViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/02.
//

import UIKit
import SnapKit

class QuestionViewController: UIViewController {
    
    private lazy var backQuestionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("이전 질문", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(backQuestion), for: .touchUpInside)
        return btn
    }()

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
        view.addSubview(backQuestionButton)
        view.addSubview(questionView)
        let safeArea = view.safeAreaLayoutGuide
        backQuestionButton.snp.makeConstraints { make in
            make.top.left.equalTo(safeArea).inset(16)
        }
        questionView.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    @objc private func backQuestion() {
        viewModel.fetchBackQuestion()
    }
    
    private func bind() {
        viewModel.formViewNextUpdateHandler = { [weak self] form in
            DispatchQueue.main.async {
                let answer = self?.questionView.next(nextForm: form)
                self?.viewModel.updateAnswer(answer: answer)
            }
        }
        viewModel.formViewBackUpdateHandler = { [weak self] form, answer in
            DispatchQueue.main.async {
                self?.questionView.back(prevForm: form, answer: answer)
            }
        }
        viewModel.subveyCompleteHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        questionView.onNextButtonTap = { [weak self] in
            self?.viewModel.fetchNextQuestion()
        }
        
        questionView.onBackButtonTap = { [weak self] in
            self?.viewModel.fetchBackQuestion()
        }
        
        questionView.subveyCompleteHandler = { [weak self] in
            self?.viewModel.submitAnswer()
        }
    }

}
