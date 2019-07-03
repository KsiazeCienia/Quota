//
//  ExchangeRateCellViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 29/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol ExchangeRateCellViewModel: class {
    var ownedCurrencyTitle: String { get }
    var orderedCurrencyTitle: String { get }
    var rateTitle: String { get }
}

final class ExchangeRateCellViewModelImp: ExchangeRateCellViewModel {

    let rateTitle: String
    let ownedCurrencyTitle: String
    let orderedCurrencyTitle: String

    init(exchangeRate: ExchangeRate) {
        self.rateTitle = "\(exchangeRate.rate)"
        self.ownedCurrencyTitle = exchangeRate.ownedCurrency.name
        self.orderedCurrencyTitle = exchangeRate.orderedCurrency.name
    }

}
