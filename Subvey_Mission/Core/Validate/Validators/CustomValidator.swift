//
//  CustomValidator.swift
//  FormManager
//
//  Created by 김도현 on 2024/01/13.
//

import Foundation

final class CustomValidator: Validator {
    let pattern: String
    
    init(pattern: String) {
        self.pattern = pattern
    }
}
