/*

 설문 화면 Controller
 현재 진행도, 설문 조사 작업 수행, 설문 내용을 APIHandler에게 전달해주는 역할 수행
 
*/

import UIKit
import SnapKit

class QuestionViewController: UIViewController {
    
    private lazy var previousQuestionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("이전 질문", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    private let progressBar: UIView = {
        let view: UIView = UIView()
        view.layer.cornerRadius = 6
        return view
    }()
    
    private var progressFillLayer: CALayer?
    
    //프로그래스바 현재 진행도 표시를 위한 프로퍼티
    private var progressPersent: CGFloat = 0.0

    let formManager: FormManager
    
    private let viewModel: QuestionViewModel
    private let questionView: QuestionView
    
    init(formManager: FormManager, viewModel: QuestionViewModel) {
        self.formManager = formManager
        self.viewModel = viewModel
        self.questionView = QuestionView(form: viewModel.getCurrentForm()!)
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        progressBar.isHidden = true
    }
    
    func previousButtonUpdate() {
        previousQuestionButton.isHidden = !formManager.isExitsPreviousQuestion()
    }

    // progressFillLayer의 x위치를 옮겨 진행도가 바뀌는 애니메이션 적용
    func updateProgress(progress: CGFloat?) {
        guard let progress else {
            DispatchQueue.main.async {
                self.progressFillLayer?.removeFromSuperlayer()
                self.progressPersent = 0.0
            }
            return
        }
        
        view.layoutIfNeeded()
                        
        progressFillLayer?.removeFromSuperlayer()
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = (progressBar.bounds.width * progressPersent - progressBar.bounds.width) + progressBar.bounds.width / 2
        animation.toValue =  (progressBar.bounds.width * progress - progressBar.bounds.width) + progressBar.bounds.width / 2
        
        animation.duration = 0.5
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        let fillLayer = CALayer()
        fillLayer.frame = CGRect(x: 0, y: 0, width: progressBar.bounds.width , height: progressBar.bounds.height)
        fillLayer.backgroundColor = UIColor.blue.cgColor
        fillLayer.add(animation, forKey: nil)
        
        progressBar.layer.addSublayer(fillLayer)
        progressFillLayer = fillLayer
        
        progressPersent = progress
    }
}

private extension QuestionViewController {
    func setup() {
        setupAddViews()
        setupAutoLayout()
        setupAction()
        previousButtonUpdate()
        bind()
    }
    
    func setupAddViews() {
        view.addSubview(progressBar)
        view.addSubview(previousQuestionButton)
        view.addSubview(questionView)
    }
    
    func setupAutoLayout() {
        let safeArea = view.safeAreaLayoutGuide
        previousQuestionButton.snp.makeConstraints { make in
            make.top.left.equalTo(safeArea).inset(16)
        }
        progressBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.height.equalTo(16)
        }
        questionView.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    func setupAction() {
        previousQuestionButton.addTarget(self, action: #selector(previousQuestion), for: .touchUpInside)
        updateProgress(progress: viewModel.getProgress())
    }
    
    @objc private func previousQuestion() {
        viewModel.fetchPreviousQuestion()
        previousButtonUpdate()
    }
    
    func bind() {
        viewModel.formViewProgressUpdateHandler = { [weak self] progress in
            self?.updateProgress(progress: progress)
        }
        
        viewModel.formViewNextUpdateHandler = { [weak self] form in
            DispatchQueue.main.async {
                let answer = self?.questionView.next(nextForm: form)
                self?.viewModel.updateAnswer(answer: answer)
                self?.previousButtonUpdate()
            }
        }
        viewModel.formViewPreviousUpdateHandler = { [weak self] form, answer in
            DispatchQueue.main.async {
                self?.questionView.previous(prevForm: form, answer: answer)
            }
        }
        viewModel.subveyCompleteHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }
        
        questionView.onNextButtonTap = { [weak self] in
            self?.viewModel.fetchNextQuestion()
            self?.previousButtonUpdate()
        }
        
        questionView.onPreviousButtonTap = { [weak self] in
            self?.viewModel.fetchPreviousQuestion()
            self?.previousButtonUpdate()
        }
        
        questionView.subveyCompleteHandler = { [weak self] in
            self?.viewModel.submitAnswer()
            self?.previousButtonUpdate()
        }
    }
}
