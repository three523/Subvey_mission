//
//  ErrorHandlerView.swift
//  Subvey_Mission
//
//  Created by 김도현 on 2024/03/20.
//

import Foundation
import UIKit

class ErrorHandlerView: UIStackView {
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    var isError: Bool = false {
        didSet {
            if isError {
                errorLabel.isHidden = false
            } else {
                errorLabel.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupInit()
        setupSubViews()
    }
    
    func setupInit() {
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
    }
    
    func setupSubViews() {
        addArrangedSubview(errorLabel)
    }
}
