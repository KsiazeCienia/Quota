//
//  Date+Extension.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

extension Date {

    func string() -> String {
        let dateForamtter = DateFormatter()
        dateForamtter.dateFormat = "dd-MM-yyyy"
        return dateForamtter.string(from: self)
    }
}
