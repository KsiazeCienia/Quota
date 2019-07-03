//
//  SplitPageViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol SplitViewModelDelegate: class {
    func splitViewModele(didCreate contributions: [Contribution])
    func splitVIewModel(didFailWith errorMessage: String)
}

protocol SplitViewModel: class {

    var delegate: SplitViewModelDelegate? { get set }

    var segmentTitles: [String] { get }
    var doneTitle: String { get }
    var proportionalSplitViewModel: ProportionalSplitViewModel { get }
    var amountSplitViewModel: AmountSplitViewModel { get }

    func doneTapped(with selectedIndex: Int)
    var onDissmis: (() -> Void)? { get set }
}

final class SplitViewModelImp: SplitViewModel {

    let segmentTitles: [String] = ["proportional".localized, "by_amount".localized]
    let doneTitle: String = "done".localized
    let proportionalSplitViewModel: ProportionalSplitViewModel
    let amountSplitViewModel: AmountSplitViewModel

    weak var delegate: SplitViewModelDelegate?
    var onDissmis: (() -> Void)?

    init(proportionalSplitViewModel: ProportionalSplitViewModel,
         amountSplitViewModel: AmountSplitViewModel) {
        self.proportionalSplitViewModel = proportionalSplitViewModel
        self.amountSplitViewModel = amountSplitViewModel
    }

    func doneTapped(with selectedIndex: Int) {
        var contributions: [Contribution]
        if selectedIndex == 0 {
            contributions = proportionalSplitViewModel.getContributions()
        } else {
            if amountSplitViewModel.balance.value != 0 {
                delegate?.splitVIewModel(didFailWith: "amount_not_zero".localized)
                return
            } else {
                contributions = amountSplitViewModel.getContributions()
            }
        }
        delegate?.splitViewModele(didCreate: contributions)
        onDissmis?()
    }

}
