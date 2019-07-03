//
//  ProportionalSplitViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

class Share {
    let member: Member
    var value: Int

    init(member: Member, value: Int) {
        self.member = member
        self.value = value
    }
}

protocol ProportionalSplitViewModel: class {
    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> ProportionalSplitCellViewModel
    func getContributions() -> [Contribution]
}

final class ProportionalSplitViewModelImp: ProportionalSplitViewModel {

    // MARK: - Observers

    private var totalNumberOfShares: BehaviorRelay<Int>
    private let disposeBag = DisposeBag()

    // MARK: - Variables

    private let amount: Double
    private let shares: [Share]
    private var cellViewModels: [ProportionalSplitCellViewModel]

    // MARK: - Initializer

    init(contributions: [Contribution], amount: Double) {
        self.amount = amount
        self.shares = contributions.map { Share(member: $0.member, value: 1) }
        self.totalNumberOfShares = BehaviorRelay<Int>(value: contributions.count)
        self.cellViewModels = []
        self.cellViewModels = shares.map(convertToCellViewModel)
    }

    init(borrowers: [Member], amount: Double) {
        self.shares = borrowers.map { Share(member: $0, value: 1) }
        self.amount = amount
        self.totalNumberOfShares = BehaviorRelay<Int>(value: borrowers.count)
        self.cellViewModels = []
        self.cellViewModels = shares.map(convertToCellViewModel)
    }

    func getContributions() -> [Contribution] {
        let shareValue = amount / Double(totalNumberOfShares.value)
        return shares.map {
            Contribution(member: $0.member,
                         value: (Double($0.value) * shareValue).rounded(toPlaces: 2))

        }
    }

    // MARK: - Table View methods

    func cellViewModel(forRowAt indexPath: IndexPath) -> ProportionalSplitCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func numberOfRows() -> Int {
        return cellViewModels.count
    }

    private func convertToCellViewModel(share: Share) -> ProportionalSplitCellViewModel {
        let cellViewModel = ProportionalSplitCellViewModelImp(share: share,
                                                              totalNumberOfShares: totalNumberOfShares,
                                                              totalAmount: amount)
        prepareCellViewModel(cellViewModel)
        return cellViewModel
    }

    private func prepareCellViewModel(_ cellViewModel: ProportionalSplitCellViewModel) {
        cellViewModel.shareUnits.filter { $0 != nil }.map { Int($0!) }.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let newTotalValue: Int = self.shares.map{ $0.value }.reduce(0, { $0 + $1 })
            self.totalNumberOfShares.accept(newTotalValue)
        }).disposed(by: disposeBag)
    }
}
