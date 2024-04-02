/*
 
 Form을 받는 UI를 가진 View의 필요한 기능들을 담은 프로토콜
 
*/

import UIKit

protocol FormReRenderView {
    var type: FormType { get }
    var form: Form { get }
    var answer: Any? { get }
    func next(nextForm: Form, answer: Any?)
    func getAnswer() -> [String: Any]?
    func validate() -> ValidateError?
    func createValidator() -> Void
}
