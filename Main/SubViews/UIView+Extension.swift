//
//  UIView+Extension.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
