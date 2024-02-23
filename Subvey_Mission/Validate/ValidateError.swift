//
//  ValidateError.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/23.
//

import Foundation

struct ValidateError: Error {
    var message: String
    init(message: String) {
        self.message = message
    }
}
