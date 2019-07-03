//
//  ExpensesViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ExpensesViewModelDelegate: class {
    func expensesViewModel(_ viewModel: ExpensesViewModel, didSelect expense: Expense)
    func closeExpenseFlow()
}

protocol ExpensesViewModel: class {

    var delegate: ExpensesViewModelDelegate? { get set }

    var reloadData: PublishRelay<Void> { get }
    var dismissAction: PublishRelay<Void> { get }

    var dissmisAsset: String { get }
    var title: String { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func selectedRow(at indexPath: IndexPath)
    func addExpense(expense: Expense)
}

final class ExpensesViewModelImp: ExpensesViewModel {

    let dissmisAsset: String = "dismiss"
    let title: String

    // MARK: - Observers

    let reloadData = PublishRelay<Void>()
    let dismissAction = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Constants

    private var expenses: [Expense] { didSet { reloadData.accept(()) } }

    // MARK: - Delegate

    weak var delegate: ExpensesViewModelDelegate?

    // MARK: - Initializer

    init(group: Group) {
        self.expenses = group.expenses
        self.title = group.name
        setupBinding()
    }

    // MARK: - Main

    func addExpense(expense: Expense) {
        expenses.insert(expense, at: 0)
    }

    // MARK: - TableView methods

    func numberOfRows() -> Int {
        return expenses.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return expenses[indexPath.row].toCellData()
    }

    func selectedRow(at indexPath: IndexPath) {
        delegate?.expensesViewModel(self, didSelect: expenses[indexPath.row])
    }

    private func setupBinding() {
        dismissAction.subscribe(onNext: { [weak self] in
            self?.delegate?.closeExpenseFlow()
        }).disposed(by: disposeBag)
    }
}
