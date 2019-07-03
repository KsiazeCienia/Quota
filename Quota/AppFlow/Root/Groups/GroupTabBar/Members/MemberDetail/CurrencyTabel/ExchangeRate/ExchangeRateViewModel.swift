//
//  ExchangeRateViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 29/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ExchangeRateViewModelDelegate: class {
    func exchangeRateViewModel(didCreate exchangeRate: ExchangeRate)
}

protocol ExchangeRateViewModelErrorDelegate: class {
     func exchangeRateViewModel(didFailWith errorMessage: String)
}

protocol ExchangeRateViewModel: class {

    var delegate: ExchangeRateViewModelDelegate? { get set }
    var errorDelegate: ExchangeRateViewModelErrorDelegate? { get set }

    var ownedCurrencyViewModel: CurrencyTextFieldViewModel { get }
    var orderedCurrencyViewModel: CurrencyTextFieldViewModel { get }
    var rate: BehaviorRelay<String?> { get }
    var ownedTitle: String { get }
    var orderedTitle: String { get }
    var rateTitle: String { get }
    var doneTitle: String { get }

    func doneTapped()

    var onDissmis: (() -> Void)? { get set }
}

final class ExchangeRateViewModelImp: ExchangeRateViewModel {

    let ownedTitle: String = "owned".localized
    let orderedTitle: String = "ordered".localized
    let rateTitle: String = "rate".localized
    let doneTitle: String = "done".localized
    private let errorMessage = "empty_fields_message".localized

    let ownedCurrencyViewModel: CurrencyTextFieldViewModel
    let orderedCurrencyViewModel: CurrencyTextFieldViewModel
    let rate: BehaviorRelay<String?>
    var onDissmis: (() -> Void)?

    weak var delegate: ExchangeRateViewModelDelegate?
    weak var errorDelegate: ExchangeRateViewModelErrorDelegate?

    init(exchangeRate: ExchangeRate?) {
        ownedCurrencyViewModel = CurrencyTextFieldViewModelImp(currencyService: CurrencyServiceImp())
        orderedCurrencyViewModel = CurrencyTextFieldViewModelImp(currencyService: CurrencyServiceImp())
        rate = BehaviorRelay<String?>(value: nil)
    }

    func doneTapped() {
        guard let ownedCurrency = ownedCurrencyViewModel.selectedCurrency.value,
            let orderedCurrency = orderedCurrencyViewModel.selectedCurrency.value,
            let rate = rate.value.commaToDecimal() else {
                errorDelegate?.exchangeRateViewModel(didFailWith: errorMessage)
                return
        }
        let exchangeRate = ExchangeRate(ownedCurrency: ownedCurrency,
                                        orderedCurrency: orderedCurrency,
                                        rate: rate)
        delegate?.exchangeRateViewModel(didCreate: exchangeRate)
        onDissmis?()
    }
}
