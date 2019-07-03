//
//  Double+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

