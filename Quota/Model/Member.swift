//
//  Member.swift
//  Quota
//
//  Created by Marcin Włoczko on 17/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

class Member: Encodable {
    let id: Int
    let name: String
    let surname: String
    let email: String?
    var totalBalance: Double
    var exchangeRates: [ExchangeRate]

    init(id: Int, name: String, surname: String, email: String?,
         totalBalance: Double = 0, exchangeRates: [ExchangeRate] = []) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.totalBalance = totalBalance
        self.exchangeRates = exchangeRates
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case surname
    }

    func hasExchangeRate(owned: Currency, ordered: Currency) -> ExchangeRate? {
        return exchangeRates.first(where: { (
            owned.code == $0.ownedCurrency.code)&&(ordered.code == $0.orderedCurrency.code) })
    }

    func toShortCellData() -> SystemTableCellViewModel {
        let memberInfo = name.capitalized + " " + surname.capitalized
        return SystemTableCellViewModelImp(title: memberInfo)
    }
}
