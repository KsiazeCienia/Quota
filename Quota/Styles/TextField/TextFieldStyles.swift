//
//  TextFieldStyles.swift
//  Quota
//
//  Created by Marcin Włoczko on 08/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

extension UITextField {

    func underlineStyle() {
        translatesAutoresizingMaskIntoConstraints = false
        font = Fonter.font(size: 16, weight: .semiBold)
        setBottomBorder()
    }

    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.alto.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
