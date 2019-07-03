//
//  CurrencyTextFieldViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CurrencyTextFieldViewModel: class {

    var placeholderTitle: String { get }
    var expandAsset: String { get }

    var selectedCurrency: BehaviorRelay<Currency?> { get }
    var reloadData: PublishRelay<Void> { get }

    func numberOfRows() -> Int
    func title(forRow row: Int) -> String
    func selected(rowAt row: Int)
}

final class CurrencyTextFieldViewModelImp: CurrencyTextFieldViewModel {

    // MARK: - View componenets

    let placeholderTitle: String = "currency_placeholder".localized
    let expandAsset: String = "expand"

    // MARK: - Observers

    let selectedCurrency: BehaviorRelay<Currency?>
    let reloadData = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Variables

    private var currencies: [Currency] = [] { didSet { reloadData.accept(()) }}

    private let currencyService: CurrencyService

    // MARK: - Initializer

    init(currencyService: CurrencyService, selected: Currency? = nil) {
        self.currencyService = currencyService
        self.selectedCurrency = BehaviorRelay<Currency?>(value: selected)
        setupBinding()
    }

    // MARK: - PickerView's methods

    func numberOfRows() -> Int {
        return currencies.count
    }

    func title(forRow row: Int) -> String {
        return currencies[row].code
    }

    func selected(rowAt row: Int) {
        selectedCurrency.accept(currencies[row])
    }

    // MARK: - Setup

    private func setupBinding() {
        currencyService.fetchCurrencies()
            .subscribe(onNext: { [weak self] currencies in
                self?.currencies = currencies
            })
            .disposed(by: disposeBag)
    }

}
