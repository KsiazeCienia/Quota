//
//  CurrencyTableViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 29/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CurrencyTableViewModelDelegate: class {
    func currencyTableViewModelDidRequestExchange(_ viewModel: CurrencyTabelViewModel,
                                                  with exchangeRate: ExchangeRate?)
}

protocol CurrencyTabelViewModel: ExchangeRateViewModelDelegate {
    var delegate: CurrencyTableViewModelDelegate? { get set }

    var reloadAction: PublishRelay<Void> { get }
    var newTitle: String { get }

    func insertTapped()
    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> ExchangeRateCellViewModel
}

final class CurrencyTabelViewModelImp: CurrencyTabelViewModel {

    // MARK: - Observers

    let reloadAction = PublishRelay<Void>()

    // MARK: - Variables

    let newTitle: String = "new".localized
    private var member: Member
    private var cellViewModels: [ExchangeRateCellViewModel] { didSet { reloadAction.accept(()) } }

    // MARK: - Delegates

    weak var delegate: CurrencyTableViewModelDelegate?

    init(member: Member) {
        self.member = member
        self.cellViewModels = member.exchangeRates.map{ ExchangeRateCellViewModelImp(exchangeRate: $0) }
    }

    func insertTapped() {
        delegate?.currencyTableViewModelDidRequestExchange(self,
                                                           with: nil)
    }

    func exchangeRateViewModel(didCreate exchangeRate: ExchangeRate) {
        DatabaseManager.shared.saveExchangeRate(exchangeRate, for: member)
        member.exchangeRates.append(exchangeRate)
        cellViewModels.append(ExchangeRateCellViewModelImp(exchangeRate: exchangeRate))
    }

    // MARK: - Table View methods

    func numberOfRows() -> Int {
        return cellViewModels.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> ExchangeRateCellViewModel {
        return cellViewModels[indexPath.row]
    }
}
