//
//  ExpensesCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

final class ExpensesCoordinator: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?
    weak var delegate: TabBarCoordinatorDelegate?

    private let builder: ExpensesBuilder
    private let expenses: [Expense]
    private let group: Group
    private let groupCurrency: Currency

    init(group: Group, builder: ExpensesBuilder) {
        self.group = group
        self.builder = builder
        self.expenses = group.expenses
        self.groupCurrency = group.currency
    }

    func start() {
        let expensesVC = builder.buildExpensesViewController(for: group)
        expensesVC.viewModel?.delegate = self
        navigationController = UINavigationController(rootViewController: expensesVC)
        root = navigationController
    }
}

extension ExpensesCoordinator: ExpensesViewModelDelegate {
    func closeExpenseFlow() {
        delegate?.closeTabBar()
    }

    func expensesViewModel(_ viewModel: ExpensesViewModel, didSelect expense: Expense) {
        let expenseDetailVC = builder.buildExpensesDetail(with: expense,
                                                          groupCurrency: groupCurrency)
        expenseDetailVC.viewModel?.delegate = self
        navigationController?.pushViewController(expenseDetailVC, animated: true)
    }
}

extension ExpensesCoordinator: ExpenseDetailViewModelDelegate {
    func expenseDetailViewModelDidRequestEditExpense(for expense: Expense) {
        let addExpenseCoordinator = builder.buildAddExpenseFlow(with: expense, for: group)
        addExpenseCoordinator.delegate = self
        rootCoordinator?.push(addExpenseCoordinator)
        navigationController?.present(addExpenseCoordinator.root!, animated: true)
    }

    func expenseDetailViewModelDidRequestBillDetail(for items: [BillItem]) {
        let billCoordinator = builder.buildBillFlow(with: items)
        billCoordinator.delegate = self
        rootCoordinator?.push(billCoordinator)
        navigationController?.present(billCoordinator.root!, animated: true)
    }
}

extension ExpensesCoordinator: BillCoordinatorDelegate {
    func closeBillCoordinator(with items: [BillItem]?) {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true)
    }
}

extension ExpensesCoordinator: AddExpenseCoordinatorDelegate {
    func closeAddExpenseCoordinator(with expense: Expense?) {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true)
        let currentIndex = navigationController!.viewControllers.count - 1
        if let expenseDetail = navigationController?.viewControllers[currentIndex] as? ExpenseDetailViewController,
            let expense = expense {
            expenseDetail.viewModel = ExpenseDetailViewModelImp(expense: expense, groupCurrency: group.currency)
            expenseDetail.viewModel?.delegate = self
        }
    }
}

