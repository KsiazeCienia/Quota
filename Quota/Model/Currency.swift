//
//  Currency.swift
//  Quota
//
//  Created by Marcin Włoczko on 18/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

struct Currency: Codable {
    /// example "$"
    let symbol: String
    /// example "US Dollar"
    let name: String
    /// example "USD"
    let code: String

    // MARK: - Mock for easier building
    init(symbol: String, name: String, code: String) {
        self.symbol = symbol
        self.name = name
        self.code = code
    }
}
