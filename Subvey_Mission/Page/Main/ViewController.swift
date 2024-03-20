//
//  ViewController.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/01/30.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
    
    private let handler = APIHandler()
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("설문 시작하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "연결에 문제가 생겼습니다.\n 다시시도해 주세요"
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isHidden = true
        return label
    }()
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
        button.isHidden = true
        return button
    }()
    private let lodingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                DispatchQueue.main.async {
                    self.lodingView.startAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.lodingView.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(startButton)
        view.addSubview(errorLabel)
        view.addSubview(refreshButton)
        view.addSubview(lodingView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        startButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(startButton)
            make.centerX.equalTo(safeArea)
        }
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom)
            make.centerX.equalTo(safeArea)
            make.height.width.equalTo(60)
        }
        lodingView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        
        startButton.addTarget(self, action: #selector(startSubvey), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(reloadSubvey), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc private func startSubvey() {
        if isLoading { return }
        fetchSubvey { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self?.presentQuestionViewController(viewModel: success.viewModel, formManager: success.formManager)
                case .failure(let failure):
                    DispatchQueue.main.async {
                        self?.hiddenErrorView(value: false)
                        switch failure {
                        case .notConnectedToInternet:
                            self?.errorLabel.text = "인터넷 연결에 문제가 있습니다.\n해결후 다시 시도해주세요"
                        default:
                            self?.errorLabel.text = "알 수 없는 문제로 설문조사 정보를 가져오지 못했습니다. \n일정 시간이 지난후에 다시 시도해주세요"
                        }
                    }
                    self?.reloadSubvey()
                }
            }
        }
    }
    
    @objc private func reloadSubvey() {
        if isLoading { return }
        fetchSubvey { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self?.presentQuestionViewController(viewModel: success.viewModel, formManager: success.formManager)
                    self?.hiddenErrorView(value: true)
                case .failure(let failure):
                    self?.hiddenErrorView(value: false)
                    switch failure {
                    case .notConnectedToInternet:
                        self?.errorLabel.text = "인터넷 연결에 문제가 있습니다.\n해결후 다시 시도해주세요"
                    default:
                        self?.errorLabel.text = "알 수 없는 문제로 설문조사 정보를 가져오지 못했습니다.\n일정 시간이 지난후에 다시 시도해주세요"
                    }
                }
            }
        }
    }
    
    func fetchSubvey(completion: @escaping (Result<(viewModel: QuestionViewModel, formManager: FormManager), SubveyError>) -> Void) {
        isLoading = true
        handler.fetchSubvey(typeID: "common") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let subvey):
                let formManager = FormManager(forms: subvey.data.forms)
                let viewModel = QuestionViewModel(formManager: formManager, apiHandler: APIHandler(), escapeValidates: subvey.data.escapeValidate)
                completion(.success((viewModel: viewModel, formManager: formManager)))
            case .failure(let failure):
                print(failure.localizedDescription)
                completion(.failure(failure))
                //TODO: 첫 설문 실패시 에러 처리
            }
            self.isLoading = false
        }
    }
    
    func presentQuestionViewController(viewModel: QuestionViewModel, formManager: FormManager) {
        DispatchQueue.main.async {
            let vc = QuestionViewController(formManager: formManager, viewModel: viewModel)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    private func hiddenErrorView(value: Bool) {
        startButton.isHidden = !value
        errorLabel.isHidden = value
        refreshButton.isHidden = value
    }

}
