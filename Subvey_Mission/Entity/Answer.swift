//
//  Answer.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/08.
//

import Foundation

struct Answer: Codable {
    let status: Int
    let data: AnswerInfo
}

struct AnswerInfo: Codable {
    let isSuccess: Bool
    let nextTypeId: String?
}
