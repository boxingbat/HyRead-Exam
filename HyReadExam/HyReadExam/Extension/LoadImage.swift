//
//  LoadImage.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: URL) {
        self.kf.setImage(with: url)
    }
}

