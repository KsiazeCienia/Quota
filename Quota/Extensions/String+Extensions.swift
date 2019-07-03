//
//  String+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 12/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Optional where Wrapped == String  {

    func commaToDecimal() -> Double? {
        guard let self = self else { return nil }
        let str = self.replacingOccurrences(of: ",", with: ".")
        return Double(str)
    }
}
