//
//  Form.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import UIKit

//TODO: 이름 고민해보기
protocol FormRenderable {
    var type: FormType { get }
    var form: Form { get }
    var answer: Any? { get }
    func next(nextForm: Form, answer: Any?)
    func getAnswer() -> [String: Any]?
    func validate() -> ValidateError?
    func createValidator() -> Void
}
