//
//  GroupsBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol GroupsBuilder {
    func buildGroupsViewController() -> GroupsViewController
    func buildGroupFlow(with group: Group) -> GroupTabBarCoordinator
    func buildInsertFlow() -> InsertGroupsCoordinator
}

final class GroupsBuilderImp: GroupsBuilder {
    func buildGroupFlow(with group: Group) -> GroupTabBarCoordinator {
        let builder = GroupTabBarBuilderImp()
        let coordinator = GroupTabBarCoordinator(group: group,
                                                 builder: builder)
        return coordinator
    }

    func buildGroupsViewController() -> GroupsViewController {
        let controller = GroupsViewController()
        controller.viewModel = GroupsViewModelImp()
        return controller
    }

    func buildInsertFlow() -> InsertGroupsCoordinator {
        let builder = InsertGroupBuilderImp()
        let coordinator = InsertGroupsCoordinator(builder: builder)
        return coordinator
    }
}
