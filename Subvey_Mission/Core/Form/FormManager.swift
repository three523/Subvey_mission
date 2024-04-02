/*
 
 서버에서 받은 모든 질문 사항(Form)을 받아 관리하는 클래스
 관리는 서버에 보낼 질문에 대한 대답, 현재 진행도, 다음 질문 전달, 이전 질문 전달 등이 있다.
 
*/

import Foundation

final class FormManager {
    var forms: [Form] {
        didSet {
            currentIndex = forms.isEmpty ? nil : 0
            prevIndex = nil
            answers = [:]
        }
    }
    // 서버에 데이터를 전달해주거나 요청할때 id를 받아야함, 새로운 Form을 받을때 새로운 값으로 변경됨
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
    
    func updateAnswer(question: String, answer: Any) {
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
    
    //이전 질문으로 돌아갈때에는 이미 작성한 설문이 있을 경우 보여줘야하기 때문에 answer도 같이 보내줌
    func previousQuestion() -> (Form?, Any?) {
        guard let prevIndex, prevIndex < forms.count else {
            return (nil, nil)
        }
        self.currentIndex = prevIndex
        self.prevIndex = prevIndex > 0 ? prevIndex - 1 : nil
        let prevForm = forms[prevIndex]
        let answer = answers[prevForm.name]
        return (forms[prevIndex], answer)
    }
    
    func isExitsPreviousQuestion() -> Bool {
        return prevIndex != nil
    }
    
    func getProgress() -> CGFloat? {
        return progress
    }
}
