//
//  UITableViewCell+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

extension UITableViewCell {
    public static var identifier: String {
        return String(describing: self)
    }
}
