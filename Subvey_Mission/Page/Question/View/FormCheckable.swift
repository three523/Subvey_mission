//
//  FormCheckable.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/02/10.
//

import Foundation

//TODO: 이름 고민해보기
protocol FormCheckable {
    var value: String? { get set }
    var radioUpdateHandler: ((String) -> Void)? { get set }
    func setupUi(option: MultiValue.Option)
    func isRadioSelected() -> Bool
    func updateSelected(isSelected: Bool)
    func getAnswer() -> [String: Any]?
}
