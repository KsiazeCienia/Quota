//
//  UIButtonStyles.swift
//  Quota
//
//  Created by Marcin Włoczko on 08/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

extension UIButton {

    func roundButtonStyle() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = Fonter.font(size: 16, weight: .semiBold)
        setTitleColor(.white, for: .normal)
        backgroundColor = .teal
        layer.cornerRadius = 10.0

        
    }

    func tealButtonStyle(fontSize: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.teal, for: .normal)
        titleLabel?.font = Fonter.font(size: fontSize, weight: .semiBold)
    }
}


