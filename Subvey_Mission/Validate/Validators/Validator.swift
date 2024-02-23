//
//  Validator.swift
//  InputManager
//
//  Created by 김도현 on 2024/01/08.
//

import Foundation

protocol Validator {
    var pattern: String { get }
    func isValid(text: String) -> Bool
}

extension Validator {
    func isValid(text: String) -> Bool {
        let range = NSRange(location: 0, length: text.count)
        let regex = try! NSRegularExpression(pattern: pattern)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
}
