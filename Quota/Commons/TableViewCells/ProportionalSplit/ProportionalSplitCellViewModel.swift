//
//  ProportionalSplitCellViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProportionalSplitCellViewModel: class {
    var shareUnits: BehaviorRelay<String?> { get }
    var memberContribution: BehaviorRelay<String> { get }
    var nameTitle: String { get }
    var shareTitle: String { get }
}

final class ProportionalSplitCellViewModelImp: ProportionalSplitCellViewModel {

    let shareTitle: String = "share".localized
    let shareUnits: BehaviorRelay<String?>
    let memberContribution: BehaviorRelay<String>
    private let totalNumberOfShares: BehaviorRelay<Int>
    private let disposeBag = DisposeBag()

    let nameTitle: String
    private var share: Share
    private let totalAmount: Double


    init(share: Share, totalNumberOfShares: BehaviorRelay<Int>, totalAmount: Double) {
        self.shareUnits = BehaviorRelay<String?>(value: String(share.value))
        let memberContributionValue = String((Double(share.value)
            / Double(totalNumberOfShares.value) * totalAmount).rounded(toPlaces: 2))
        let memeberContributionString = String(format: "%.2f", memberContributionValue)
        self.memberContribution = BehaviorRelay<String>(value: memeberContributionString)
        self.nameTitle = share.member.name + " " + share.member.surname
        self.totalNumberOfShares = totalNumberOfShares
        self.totalAmount = totalAmount
        self.share = share
        setupBinding()
    }

    private func setupBinding() {
        totalNumberOfShares
            .map { [weak self] value in
                guard let self = self else { return "" }
                return String(format: "%.2f",
                              Double(self.share.value) / Double(value) * self.totalAmount)
            }
            .bind(to: memberContribution)
            .disposed(by: disposeBag)

        shareUnits.filter { $0 != nil }.map { Int($0!) }.subscribe(onNext: { [weak self] optionalValue in
            guard let value = optionalValue else { return }
            self?.share.value = value
        }).disposed(by: disposeBag)
    }
}
