//
//  AmountSplitViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AmountSplitViewModel: class {

    var balance: BehaviorRelay<Double> { get }

    func cellViewModel(forRowAt indexPath: IndexPath) -> AmountSplitCellViewModel
    func numberOfRows() -> Int
    func getContributions() -> [Contribution]
}

final class AmountSplitViewModelImp: AmountSplitViewModel {

    // MARK: - Observers

    let balance: BehaviorRelay<Double>
    private let disposeBag = DisposeBag()

    // MARK: - Variables

    private let amount: Double
    private let contributions: [Contribution]
    private var cellViewModels: [AmountSplitCellViewModel]

    // MARK: - Initializers

    init(contributions: [Contribution], amount: Double) {
        self.amount = amount
        self.contributions = contributions
        let amountLeft = amount - contributions.map{ $0.value }.reduce(0, { $0 + $1 })
        self.balance = BehaviorRelay<Double>(value: amountLeft)
        self.cellViewModels = []
        self.cellViewModels = contributions.map(convertToCellViewModel)
    }

    init(borrowers: [Member], amount: Double) {
        self.amount = amount
        self.contributions = borrowers.map{ Contribution(member: $0, value: 0) }
        self.balance = BehaviorRelay<Double>(value: amount)
        self.cellViewModels = []
        self.cellViewModels = contributions.map(convertToCellViewModel)
    }

    // MARK: - Main

    func getContributions() -> [Contribution] {
        return contributions
    }

    // MARK: - Table View methods

    func cellViewModel(forRowAt indexPath: IndexPath) -> AmountSplitCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func numberOfRows() -> Int {
        return contributions.count
    }

    private func convertToCellViewModel(contribution: Contribution) -> AmountSplitCellViewModel {
        let cellViewModel = AmountSplitCellViewModelImp(contribution: contribution)
        prepareCellViewModel(cellViewModel)
        return cellViewModel
    }

    private func prepareCellViewModel(_ cellViewModel: AmountSplitCellViewModel) {

        cellViewModel.amount
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let newBalance = self.amount - self.contributions
                                                        .map { $0.value }
                                                        .reduce(0, { $0 + $1 })
                self.balance.accept(newBalance)
            }).disposed(by: disposeBag)
    }
}


