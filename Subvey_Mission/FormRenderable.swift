//
//  Form.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/07.
//

import Foundation

protocol FormRenderable {
    var type: FormType { get }
    var form: Form { get }
    // 다음질문으로 넘어갈때 입력했던 값을 리턴해줘야함
    func next(nextForm: Form) -> [String: Any]?
    func getAnswer() -> [String: Any]?
}
