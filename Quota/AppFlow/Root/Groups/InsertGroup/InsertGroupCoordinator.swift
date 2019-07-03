//
//  InsertGroupsCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 13/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol InsertGroupCoordinatorDelegate: class {
    func closeInsertGroupsFlow(with group: Group?)
}

final class InsertGroupsCoordinator: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?

    weak var delegate: InsertGroupCoordinatorDelegate?

    private let builder: InsertGroupBuilder

    init(builder: InsertGroupBuilder) {
        self.builder = builder
    }

    func start() {
        let insertGroupVC = builder.buildInsertGroupViewController()
        insertGroupVC.viewModel?.delegate = self
        navigationController = UINavigationController(rootViewController: insertGroupVC)
        root = navigationController
    }
}

extension InsertGroupsCoordinator: InsertGroupViewModelDelegate {
    func insertGroupViewModel(didFailWith errorMessage: String) {
        UIAlertController.showAlert(withTitle: "", message: errorMessage)
    }

    func insertGroupViewModelDidTapAddUser(_ viewModel: InsertGroupViewModel) {
        let memberVC = builder.buildMemberViewController()
        memberVC.viewModel?.onDissmis = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        memberVC.viewModel?.delegate = viewModel
        navigationController?.pushViewController(memberVC, animated: true)
    }

    func insertGroupViewModel(didCreate group: Group) {
        delegate?.closeInsertGroupsFlow(with: group)
    }

    func insertGroupViewModelDidTapCancel() {
        delegate?.closeInsertGroupsFlow(with: nil)
    }
}

extension InsertGroupsCoordinator: MemberViewModelErrorDelegate {
    func memberViewModel(didFailWith errorMessage: String) {
        UIAlertController.showAlert(withTitle: "", message: errorMessage)
    }
}
