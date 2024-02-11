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
    
    var formViewNextUpdateHandler: ((Form?) -> Void)?
    var formViewBackUpdateHandler: ((Form?, Any?) -> Void)?
    var subveyCompleteHandler: (() -> Void)?
    
    init(formManager: FormManager, apiHandler: APIHandler) {
        self.formManager = formManager
        self.apiHandler = apiHandler
    }
    
    func fetchNextQuestion() {
        let nextForm = formManager.nextQuestion()
        formViewNextUpdateHandler?(nextForm)
    }
    
    func fetchBackQuestion() {
        var (backForm, answer) = formManager.backQuestion()
        guard let backForm else { return }
        formViewBackUpdateHandler?(backForm, answer)
    }
    
    func updateAnswer(answer: [String: Any]?) {
        formManager.updateAnswer(answer: answer)
    }
    
    func nextQuestionTap() {
        let form = formManager.nextQuestion()
        formViewNextUpdateHandler?(form)
    }
    
    func getCurrentForm() -> Form? {
        return formManager.getCurrentForm()
    }
    
    func submitAnswer() {
        guard formManager.answers.isEmpty == false else {
            //TODO: 작성을 안했을 경우 에러 메세지 처리
            print("작성한 내용이 없습니다.")
            return
        }
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
                                self?.formViewNextUpdateHandler?(forms.first)
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
