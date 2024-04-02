//
//  ValidateError.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/23.
//

import Foundation

struct ValidateError: Error {
    var message: String
    var action: (() -> Void)? = nil
    
    init(message: String) {
        self.message = message
    }
    
    init(message: String, action: @escaping (() -> Void)) {
        self.init(message: message)
        self.action = action
    }
}
