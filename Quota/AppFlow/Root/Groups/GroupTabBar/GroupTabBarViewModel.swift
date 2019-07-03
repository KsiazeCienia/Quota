//
//  GroupTabBarViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol GroupTabBarViewModelDelegate: class {
    func groupTabBarViewModelDidTapAddExpense()
}

protocol GroupTabBarViewModel: class {

    var delegate: GroupTabBarViewModelDelegate? { get set }

    var expensesTitle: String { get }
    var membersTitle: String { get }
    var expensesAsset: String { get }
    var membersAsset: String { get }
    var addExpenseTitle: String { get }

    var addExpenseAction: PublishRelay<Void> { get }
}

final class GroupTabBarViewModelImp: GroupTabBarViewModel {

    // MARK: - View's constants

    let expensesTitle: String = "expenses".localized
    let membersTitle: String = "members".localized
    let expensesAsset: String = "expenses"
    let membersAsset: String = "members"
    let addExpenseTitle: String = "add"

    // MARK: - Observers

    let addExpenseAction = PublishRelay<Void>()

    // MARK: - Delegate

    weak var delegate: GroupTabBarViewModelDelegate?

    // MARK: - Constants

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        setupBinding()
    }

    // MARK: - Setup

    private func setupBinding() {
        addExpenseAction.subscribe(onNext: { [weak self] in
            self?.delegate?.groupTabBarViewModelDidTapAddExpense()
        }).disposed(by: disposeBag)
    }
}




