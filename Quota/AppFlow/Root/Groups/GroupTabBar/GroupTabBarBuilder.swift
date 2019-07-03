//
//  GroupTabBarBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol GroupTabBarBuilder: class {
    func buildGroupTabBarController() -> GroupTabBarController
    func buildExpensesFlow(with group: Group) -> ExpensesCoordinator
    func buildMembersFlow(with group: Group) -> MembersCoordinator
    func buildAddExpenseFlow(with group: Group) -> AddExpenseCoordinator
}

final class GroupTabBarBuilderImp: GroupTabBarBuilder {
    func buildGroupTabBarController() -> GroupTabBarController {
        let tabBarController = GroupTabBarController()
        tabBarController.viewModel = GroupTabBarViewModelImp()
        return tabBarController
    }

    func buildExpensesFlow(with group: Group) -> ExpensesCoordinator {
        let builder = ExpensesBuilderImp()
        let coordinator = ExpensesCoordinator(group: group, builder: builder)
        return coordinator
    }

    func buildMembersFlow(with group: Group) -> MembersCoordinator {
        let builder = MembersBuilderImp()
        let coordinator = MembersCoordinator(group: group, builder: builder)
        return coordinator
    }

    func buildAddExpenseFlow(with group: Group) -> AddExpenseCoordinator {
        let builder = AddExpenseBuilderImp()
        let coordiantor = AddExpenseCoordinator(builder: builder, group: group)
        return coordiantor
    }
}
