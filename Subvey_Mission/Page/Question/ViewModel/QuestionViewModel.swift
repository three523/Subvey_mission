//
//  QuestionViewModel.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/08.
//

import Foundation

final class QuestionViewModel {
    private let formManager: FormManager
    private let apiHandler: APIHandler
    
    var formViewUpdateHandler: ((Form?) -> Void)?
    var subveyCompleteHandler: (() -> Void)?
    
    init(formManager: FormManager, apiHandler: APIHandler) {
        self.formManager = formManager
        self.apiHandler = apiHandler
    }
    
    func fetchNextQuestion() {
        let nextForm = formManager.nextQuestion()
        formViewUpdateHandler?(nextForm)
    }
    
    func updateAnswer(answer: [String: Any]?) {
        formManager.updateAnswer(answer: answer)
    }
    
    func nextQuestionTap() {
        let form = formManager.nextQuestion()
        formViewUpdateHandler?(form)
    }
    
    func getCurrentForm() -> Form? {
        return formManager.getCurrentForm()
    }
    
    func submitAnswer() {
        apiHandler.submitSubery(typeId: formManager.typeId, sendData: formManager.answers) { [weak self] result in
            switch result {
            case .success(let answer):
                if let nextTypeId = answer.data.nextTypeId {
                    self?.formManager.typeId = nextTypeId
                    self?.apiHandler.fetchSubvey(typeID: nextTypeId) { result in
                        switch result {
                        case .success(let subvey):
                            let forms = subvey.data.forms
                            self?.formManager.forms = forms
                            DispatchQueue.main.async {
                                self?.formViewUpdateHandler?(forms.first)
                            }
                        case .failure(let failure):
                            print(failure.localizedDescription)
                            //TODO: 연결 설문 내용을 못받은 경우 구현
                        }
                    }
                } else {
                    self?.subveyCompleteHandler?()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
                //TODO: 설문 전달 후 응답을 못받은 경우 구현
            }
        }
    }
}
