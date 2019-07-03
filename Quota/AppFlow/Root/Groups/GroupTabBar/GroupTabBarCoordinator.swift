//
//  GroupTabBarCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

enum TabBarItem {
    case expenses
    case members
}

protocol TabBarCoordinatorDelegate: class {
    func closeTabBar()
}

protocol GroupTabBarCoordinatorDelegate: class {
    func groupTabBarDidRequestDismiss()
}

final class GroupTabBarCoordinator: NSObject, Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController? {
        guard let selectedItem = selectedItem else { return nil }
        return coordinator(for: selectedItem).navigationController
    }
    var root: UIViewController?
    weak var delegate: GroupTabBarCoordinatorDelegate?

    private var selectedItem: TabBarItem?

    private let builder: GroupTabBarBuilder
    private var group: Group

    private lazy var expensesCoordinator: ExpensesCoordinator = {
        let coordinator = builder.buildExpensesFlow(with: group)
        coordinator.delegate = self
        return coordinator
    }()

    private lazy var membersCoordinator: MembersCoordinator = {
        let coordinator = builder.buildMembersFlow(with: group)
        coordinator.delegate = self
        return coordinator
    }()

    init(group: Group, builder: GroupTabBarBuilder) {
        self.builder = builder
        self.group = group
    }

    func start() {
        rootCoordinator?.push(expensesCoordinator)
        rootCoordinator?.push(membersCoordinator)

        let groupTBC = builder.buildGroupTabBarController()
        groupTBC.viewModel?.delegate = self
        groupTBC.delegate = self
        selectedItem = .expenses
        root = groupTBC
        groupTBC.setViewControllers([expensesCoordinator.root!,
                                     membersCoordinator.root!],
                                    animated: false)
    }

    private func coordinator(for item: TabBarItem) -> Coordinator {
        switch item {
        case .expenses: return expensesCoordinator
        case .members: return membersCoordinator
        }
    }
}

extension GroupTabBarCoordinator: GroupTabBarViewModelDelegate {
    func groupTabBarViewModelDidTapAddExpense() {
        let addExpenseCoordinator = builder.buildAddExpenseFlow(with: group)
        addExpenseCoordinator.delegate = self
        rootCoordinator?.push(addExpenseCoordinator)
        navigationController?.present(addExpenseCoordinator.root!,
                                      animated: true,
                                      completion: nil)
    }
}

extension GroupTabBarCoordinator: AddExpenseCoordinatorDelegate {
    func closeAddExpenseCoordinator(with expense: Expense?) {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true, completion: nil)
        guard let expense = expense else { return }
        guard let expensesVC = expensesCoordinator.navigationController?
            .viewControllers[0] as? ExpensesViewController else { return }
        expensesVC.viewModel?.addExpense(expense: expense)
        guard let membersVC = membersCoordinator.navigationController?
            .viewControllers[0] as? MembersViewController else { return }
        membersVC.refresh()
    }
}

extension GroupTabBarCoordinator: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController {
        case membersCoordinator.root:
            selectedItem = .members
        case expensesCoordinator.root:
            selectedItem = .expenses
        default:
            break
        }
    }
}

extension GroupTabBarCoordinator: TabBarCoordinatorDelegate {
    func closeTabBar() {
        rootCoordinator?.pop()
        rootCoordinator?.pop()
        delegate?.groupTabBarDidRequestDismiss()
    }
}
