//
//  ExpensesBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol ExpensesBuilder {
    func buildExpensesViewController(for group: Group) -> ExpensesViewController
    func buildExpensesDetail(with expense: Expense,
                             groupCurrency: Currency) -> ExpenseDetailViewController
    func buildBillFlow(with items: [BillItem]) -> BillCoordinator
    func buildAddExpenseFlow(with expense: Expense, for group: Group) -> AddExpenseCoordinator
}

final class ExpensesBuilderImp: ExpensesBuilder {
    func buildExpensesViewController(for group: Group) -> ExpensesViewController {
        let expensesVC = ExpensesViewController()
        expensesVC.viewModel = ExpensesViewModelImp(group: group)
        return expensesVC
    }

    func buildExpensesDetail(with expense: Expense, groupCurrency: Currency) -> ExpenseDetailViewController {
        let expenseDetailVC = ExpenseDetailViewController()
        expenseDetailVC.viewModel = ExpenseDetailViewModelImp(expense: expense,
                                                              groupCurrency: groupCurrency)
        return expenseDetailVC
    }

    func buildBillFlow(with items: [BillItem]) -> BillCoordinator {
        let builder = BillBuilderImp()
        let coordinator = BillCoordinator(builder: builder, items: items)
        return coordinator
    }

    func buildAddExpenseFlow(with expense: Expense, for group: Group) -> AddExpenseCoordinator {
        let builder = AddExpenseBuilderImp()
        let coordinator = AddExpenseCoordinator(builder: builder,
                                                group: group,
                                                expense: expense)
        return coordinator
    }
}
