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
    private var escapeValidates: [EscapeValidate]
    
    var formViewNextUpdateHandler: ((Form?) -> Void)?
    var formViewPreviousUpdateHandler: ((Form?, Any?) -> Void)?
    var formViewProgressUpdateHandler: ((CGFloat?) -> Void)?
    var subveyCompleteHandler: (() -> Void)?
    
    init(formManager: FormManager, apiHandler: APIHandler, escapeValidates: [EscapeValidate]) {
        self.formManager = formManager
        self.apiHandler = apiHandler
        self.escapeValidates = escapeValidates
    }
    
    func fetchNextQuestion() {
        let nextForm = formManager.nextQuestion()
        formViewProgressUpdateHandler?(formManager.getProgress())
        formViewNextUpdateHandler?(nextForm)
    }
    
    func fetchPreviousQuestion() {
        let (previousForm, answer) = formManager.previousQuestion()
        guard let previousForm else { return }
        formViewProgressUpdateHandler?(formManager.getProgress())
        formViewPreviousUpdateHandler?(previousForm, answer)
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
    
    func getProgress() -> CGFloat {
        return formManager.progress ?? 0.0
    }
    
    func submitAnswer() {
        guard formManager.answers.isEmpty == false else {
            //TODO: 작성을 안했을 경우 에러 메세지 처리
            print("작성한 내용이 없습니다.")
            return
        }
        if isValidate() == false {
            formManager.typeId = "done"
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
                                self?.formViewProgressUpdateHandler?(self?.formManager.getProgress())
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
    
    func isValidate() -> Bool {
        for validate in escapeValidates {
            if validate.type == "not" {
                switch validate.target {
                case .int(let compareValue):
                    if NotEqualValidation(fieldName: validate.name, compareValue: compareValue).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .emptyArray:
                    //TODO: EmptyArray의 경우 어떻게 처리할지 고민해보기 현재 Array 타입을 알 수 없어 빈 값을 비교가 불가능함
                    if NotEqualValidation(fieldName: validate.name, compareValue: [String]()).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .boolArray(let boolArray):
                    if NotEqualValidation(fieldName: validate.name, compareValue: boolArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .intArray(let intArray):
                    if NotEqualValidation(fieldName: validate.name, compareValue: intArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .string(let string):
                    if NotEqualValidation(fieldName: validate.name, compareValue: string).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .stringArray(let stringArray):
                    if NotEqualValidation(fieldName: validate.name, compareValue: stringArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "minMax" {
                switch validate.target {
                case .minMax(let minMax):
                    if let minValue = minMax.first {
                        switch minValue {
                        case .int(let min):
                            if MinValidation(fieldName: validate.name, minLength: min).validate(data: formManager.answers) != nil {
                                return false
                            }
                        case .string(_): break
                        }
                    }
                    if let maxValue = minMax.last {
                        switch maxValue {
                        case .int(let max):
                            if MaxValidation(fieldName: validate.name, maxLength: max).validate(data: formManager.answers) != nil {
                                return false
                            }
                        case .string(_): break
                        }
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            }
            else if validate.type == "minMaxLength" {
                var minLength = 0
                var maxLength = 0
                switch validate.target {
                case .minMax(let minMax):
                    if let minValue = minMax.first {
                        switch minValue {
                        case .int(let min):
                            minLength = min
                        case .string(_): break
                        }
                    }
                    if let maxValue = minMax.last {
                        switch maxValue {
                        case .int(let max):
                            maxLength = max
                        case .string(_): break
                        }
                    }
                    MinMaxLengthValidation(fieldName: validate.name, minLength: minLength, maxLength: maxLength)
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "sameAS" {
                switch validate.target {
                case .int(let compareValue):
                    if ConfirmValidation(fieldName: validate.name, compareValue: compareValue).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .emptyArray:
                    //TODO: 비어있는 Array 값 타입을 모를 경우 어떻게 처리할 수 있을지 생각해보기
                    if ConfirmValidation(fieldName: validate.name, compareValue: [String]()).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .boolArray(let boolArray):
                    if ConfirmValidation(fieldName: validate.name, compareValue: boolArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .intArray(let intArray):
                    if ConfirmValidation(fieldName: validate.name, compareValue: intArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .string(let string):
                    if ConfirmValidation(fieldName: validate.name, compareValue: string).validate(data: formManager.answers) != nil {
                        return false
                    }
                case .stringArray(let stringArray):
                    if ConfirmValidation(fieldName: validate.name, compareValue: stringArray).validate(data: formManager.answers) != nil {
                        return false
                    }
                default:
                    print("잘못된 ValidateTarget 입니다.\(validate.target)")
                    break
                }
            } else if validate.type == "pattern" {
                switch validate.target {
                case .string(let pattern):
                    if CustomValidation(fieldName: validate.name, pattern: pattern).validate(data: formManager.answers) != nil {
                        return false
                    }
                default:
                    print("Validate Target 형식이 맞지 않습니다. \(validate.target)")
                }
            }
        }
        return true
    }
}
