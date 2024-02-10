//
//  Form.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import Foundation

//TODO: 이름 고민해보기
protocol FormRenderable {
    var type: FormType { get }
    var form: Form { get }
    func next(nextForm: Form)
    func getAnswer() -> [String: Any]?
}
