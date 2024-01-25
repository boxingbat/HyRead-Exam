//
//  Font-Extention.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import UIKit

extension UIFont {

    static func pingFangTCRegular(size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: "PingFangTC-Regular", size: size) {
            return customFont
        } else {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
}

