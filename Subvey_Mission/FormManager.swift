//
//  FormManager.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/10.
//

import Foundation

final class FormManager {
    var forms: [Form] {
        didSet {
            currentIndex = forms.isEmpty ? nil : 0
            prevIndex = nil
            answers = [:]
        }
    }
    var typeId: String = "common"
    var currentIndex: Int? {
        didSet {
            guard let currentIndex else {
                progress = nil
                return
            }
            progress = CGFloat(currentIndex + 1) / CGFloat(forms.count)
        }
    }
    var prevIndex: Int?
    var answers: [String: Any] = [:]
    
    var progress: CGFloat?
    
    init(forms: [Form]) {
        self.forms = forms
        currentIndex = forms.isEmpty ? nil : 0
        progress = forms.isEmpty ? nil : (1.0 / CGFloat(forms.count))
    }
    
    func getCurrentForm() -> Form? {
        guard let currentIndex else { return nil }
        return forms[currentIndex]
    }
    
    func updateValue(question: String, answer: Any) {
        answers[question] = answer
    }
    
    func updateAnswer(answer: [String: Any]?) {
        guard let answer else { return }
        answers.merge(answer, uniquingKeysWith: { (oldValue, newValue) in newValue })
        
        //TODO: 로컬에 설문 내용 저장하는 기능 구현
    }
    
    func updateForms(newforms: [Form]) {
        forms = newforms
    }
    
    func nextQuestion() -> Form? {
        guard let currentIndex, currentIndex + 1 < forms.count else {
            self.prevIndex = currentIndex
            self.currentIndex = nil
            return nil
        }
        self.prevIndex = currentIndex
        let nextIndex = currentIndex + 1
        self.currentIndex = nextIndex
        return forms[nextIndex]
    }
    
    func backQuestion() -> (Form?, Any?) {
        guard let prevIndex, prevIndex < forms.count else {
            return (nil, nil)
        }
        self.currentIndex = prevIndex
        self.prevIndex = prevIndex > 0 ? prevIndex - 1 : nil
        let prevForm = forms[prevIndex]
        let answer = answers[prevForm.name]
        return (forms[prevIndex], answer)
    }
    
    func isExitsBackQuestion() -> Bool {
        return prevIndex != nil
    }
    
    func getProgress() -> CGFloat? {
        return progress
    }
}
