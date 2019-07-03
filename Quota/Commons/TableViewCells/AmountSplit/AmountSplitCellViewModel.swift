//
//  AmountSplitCellViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 28/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AmountSplitCellViewModel: class {
    var amount: BehaviorRelay<String?> { get }
    var nameTitle: String { get }
    var amountPlaceholder: String { get }
    var initialTitle: String? { get }
}

final class AmountSplitCellViewModelImp: AmountSplitCellViewModel {
    let amount: BehaviorRelay<String?>
    private let disposeBag = DisposeBag()
    let nameTitle: String
    let amountPlaceholder: String = "amount".localized
    let initialTitle: String?
    private var contribution: Contribution

    init(contribution: Contribution) {
        self.amount = BehaviorRelay<String?>(value: String(contribution.value))
        self.nameTitle = contribution.member.name + " " + contribution.member.surname
        self.contribution = contribution
        self.initialTitle = contribution.value != 0 ? String(contribution.value) : nil
        setupBinding()
    }

    private func setupBinding() {
        amount.map{ $0.commaToDecimal() }.subscribe(onNext: { [weak self] value in
            guard let accValue = value else { return }
            self?.contribution.value = accValue
        }).disposed(by: disposeBag)
    }
}
