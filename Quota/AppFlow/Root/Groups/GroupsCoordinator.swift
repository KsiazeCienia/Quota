//
//  GroupsCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 07/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

final class GroupsCoordiantor: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?

    private let builder: GroupsBuilder

    init(builder: GroupsBuilder) {
        self.builder = builder
    }

    func start() {
        let groupsVC = builder.buildGroupsViewController()
        groupsVC.viewModel?.delegate = self
        navigationController = UINavigationController(rootViewController: groupsVC)
        root = navigationController
    }
}

extension GroupsCoordiantor: GroupsViewModelDelegate {
    func groupsViewModelDidTapInsert() {
        let insertCoordinator = builder.buildInsertFlow()
        insertCoordinator.delegate = self
        rootCoordinator?.push(insertCoordinator)
        navigationController?.present(insertCoordinator.navigationController!, animated: true, completion: nil)
    }

    func groupsViewModel(didSelect group: Group) {
        let groupCoordinator = builder.buildGroupFlow(with: group)
        groupCoordinator.delegate = self
        rootCoordinator?.push(groupCoordinator)
        navigationController?.present(groupCoordinator.root!, animated: true)
    }
}

extension GroupsCoordiantor: InsertGroupCoordinatorDelegate {
    func closeInsertGroupsFlow(with group: Group?) {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true, completion: nil)
        guard let group = group else { return }
        guard let groupsVC = navigationController?.viewControllers.last as? GroupsViewController else { return }
        groupsVC.viewModel?.addGroup(group)
    }
}

extension GroupsCoordiantor: GroupTabBarCoordinatorDelegate {
    func groupTabBarDidRequestDismiss() {
        rootCoordinator?.pop()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
