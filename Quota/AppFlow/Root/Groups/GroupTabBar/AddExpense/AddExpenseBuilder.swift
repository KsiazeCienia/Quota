//
//  AddExpenseBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol AddExpenseBuilder {
    func buildAddExpenseViewController(for group: Group) -> AddExpenseViewController
    func buildPayerViewController(with members: [Member],
                                  currentPayer: Member?) -> SelectableListViewController
    func buildBorrowersViewController(with members: [Member],
                                      currentBorrowes: [Member]) -> SelectableListViewController
    func buildSplitViewController(with contributions: [Contribution],
                                  amount: Double) -> SplitViewController
    func buildSplitViewController(with borrowers: [Member],
                                  amount: Double) -> SplitViewController
    func buildAddExpense(for group: Group, expense: Expense) -> AddExpenseViewController
    func buildBillFlow() -> BillCoordinator
    func buildBillFlow(with items: [BillItem]) -> BillCoordinator
}

final class AddExpenseBuilderImp: AddExpenseBuilder {
    func buildAddExpenseViewController(for group: Group) -> AddExpenseViewController {
        let controller = AddExpenseViewController()
        let service = CurrencyServiceImp()
        let expenseCalculator = ExpensesCalculatorImp()
        let textFieldViewModel = CurrencyTextFieldViewModelImp(currencyService: service,
                                                               selected: group.currency)
        let dateTextFieldViewModel = DateTextFieldViewModelImp()
        let viewModel = AddExpenseViewModelImp(currencyTextFiledViewModel: textFieldViewModel,
                                               dateTextFieldViewModel: dateTextFieldViewModel,
                                               expenseCalculator: expenseCalculator,
                                               group: group)
        controller.viewModel = viewModel
        return controller
    }

    func buildPayerViewController(with members: [Member],
                                  currentPayer: Member?) -> SelectableListViewController {
        let controller = SelectableListViewController()
        controller.viewModel = PayerViewModel(members: members,
                                                  currentPayer: currentPayer)
        return controller
    }

    func buildBorrowersViewController(with members: [Member],
                                      currentBorrowes: [Member]) -> SelectableListViewController {
        let controller = SelectableListViewController()
        controller.viewModel = BorrowersViewModel(members: members,
                                                  currentBorrowers: currentBorrowes)
        return controller
    }

    func buildSplitViewController(with contributions: [Contribution], amount: Double) -> SplitViewController {
        let proportionalVM = ProportionalSplitViewModelImp(contributions: contributions, amount: amount)
        let amountVM = AmountSplitViewModelImp(contributions: contributions, amount: amount)
        let viewModel = SplitViewModelImp(proportionalSplitViewModel: proportionalVM,
                                          amountSplitViewModel: amountVM)
        let controller = SplitViewController()
        controller.viewModel = viewModel
        return controller
    }

    func buildSplitViewController(with borrowers: [Member],
                                  amount: Double) -> SplitViewController {
        let proportionalVM = ProportionalSplitViewModelImp(borrowers: borrowers, amount: amount)
        let amountVM = AmountSplitViewModelImp(borrowers: borrowers, amount: amount)
        let viewModel = SplitViewModelImp(proportionalSplitViewModel: proportionalVM,
                                          amountSplitViewModel: amountVM)
        let controller = SplitViewController()
        controller.viewModel = viewModel
        return controller
    }

    func buildBillFlow() -> BillCoordinator {
        let builder = BillBuilderImp()
        let coordinator = BillCoordinator(builder: builder)
        return coordinator
    }

    func buildBillFlow(with items: [BillItem]) -> BillCoordinator {
        let builder = BillBuilderImp()
        let coordinator = BillCoordinator(builder: builder, items: items)
        return coordinator
    }

    func buildAddExpense(for group: Group, expense: Expense) -> AddExpenseViewController {
        let controller = AddExpenseViewController()
        let service = CurrencyServiceImp()
        let expenseCalculator = ExpensesCalculatorImp()
        let textFieldViewModel = CurrencyTextFieldViewModelImp(currencyService: service,
                                                               selected: expense.currency)
        let dateTextFieldViewModel = DateTextFieldViewModelImp(date: expense.date)
        let viewModel = AddExpenseViewModelImp(currencyTextFiledViewModel: textFieldViewModel,
                                               dateTextFieldViewModel: dateTextFieldViewModel,
                                               expenseCalculator: expenseCalculator,
                                               group: group, expense: expense)
        controller.viewModel = viewModel
        return controller
    }
}
