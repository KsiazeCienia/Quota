//
//  AddExpenseCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol AddExpenseCoordinatorDelegate: class {
    func closeAddExpenseCoordinator(with expense: Expense?)
}

final class AddExpenseCoordinator: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?

    weak var delegate: AddExpenseCoordinatorDelegate?

    private let builder: AddExpenseBuilder
    private let group: Group
    private let expense: Expense?

    init(builder: AddExpenseBuilder, group: Group, expense: Expense? = nil) {
        self.builder = builder
        self.group = group
        self.expense = expense
    }

    func start() {
        var addExpenseVC: AddExpenseViewController
        if let expense = expense {
            addExpenseVC = builder.buildAddExpense(for: group, expense: expense)
        } else {
            addExpenseVC = builder.buildAddExpenseViewController(for: group)
        }
        addExpenseVC.viewModel?.delegate = self
        navigationController = UINavigationController(rootViewController: addExpenseVC)
        root = navigationController
    }
}

extension AddExpenseCoordinator: AddExpenseViewModelDelegate {
    func addExpenseViewModelDidRequestBillFlow(with items: [BillItem]?) {
        var billCoordinator: BillCoordinator
        if  let items = items {
            billCoordinator = builder.buildBillFlow(with: items)
        } else {
            billCoordinator = builder.buildBillFlow()
        }
        billCoordinator.delegate = self
        rootCoordinator?.push(billCoordinator)
        navigationController?.present(billCoordinator.root!, animated: true)
    }

    func addExpenseViewModel(didFailWith errorMessage: String) {
        UIAlertController.showAlert(withTitle: "", message: errorMessage)
    }

    func addExpenseViewModelDidRequestSplit(_ viewModel: AddExpenseViewModel,
                                            with borrowers: [Member], amount: Double) {
        let splitVC = builder.buildSplitViewController(with: borrowers, amount: amount)
        splitVC.viewModel?.delegate  = viewModel
        splitVC.viewModel?.onDissmis = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(splitVC, animated: true)
    }

    func addExpenseViewModelDidRequestSplit(_ viewModel: AddExpenseViewModel,
                                            with contributions: [Contribution], amount: Double) {
        let splitVC = builder.buildSplitViewController(with: contributions, amount: amount)
        splitVC.viewModel?.delegate  = viewModel
        splitVC.viewModel?.onDissmis = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(splitVC, animated: true)
    }

    func addExpenseViewModelDidRequestPayer(_ viewModel: AddExpenseViewModel, currentPayer: Member?) {
        let payerVC = builder.buildPayerViewController(with: group.members,
                                                       currentPayer: currentPayer)
        payerVC.viewModel?.delegate = viewModel
        payerVC.viewModel?.onDissmis = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(payerVC, animated: true)
    }

    func addExpenseViewModelDidRequestBorrowers(_ viewModel: AddExpenseViewModel, currentBorrowers: [Member]) {
        let payerVC = builder.buildBorrowersViewController(with: group.members,
                                                           currentBorrowes: currentBorrowers)
        payerVC.viewModel?.delegate = viewModel
        payerVC.viewModel?.onDissmis = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(payerVC, animated: true)
    }

    func addExpenseViewModelDidRequestDismiss() {
        delegate?.closeAddExpenseCoordinator(with: nil)
    }

    func addExpenseViewModel(didCreate expense: Expense) {
        delegate?.closeAddExpenseCoordinator(with: expense)
    }
}

extension AddExpenseCoordinator: BillCoordinatorDelegate {
    func closeBillCoordinator(with items: [BillItem]?) {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true)
        guard let items = items else { return }
        let controller = navigationController?.viewControllers[0] as! AddExpenseViewController
        controller.viewModel?.addItems(items)
    }
}
