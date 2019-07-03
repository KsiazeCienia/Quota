//
//  MembersCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

final class MembersCoordinator: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?
    weak var delegate: TabBarCoordinatorDelegate?

    private let builder: MembersBuilder
    private let group: Group

    init(group: Group, builder: MembersBuilder) {
        self.builder = builder
        self.group = group
    }

    func start() {
        let membersVC = builder.buildMembersViewController(with: group)
        membersVC.viewModel?.delegate = self
        navigationController = UINavigationController(rootViewController: membersVC)
        root = navigationController
    }
}

extension MembersCoordinator: MembersViewModelDelegate {
    func closeMembersFlow() {
        delegate?.closeTabBar()
    }

    func membersViewModel(didSelect member: Member) {
        let memberDetailVC = builder.buildMemberDetailViewController(with: member,
                                                                     in: group)
        memberDetailVC.viewModel?.delegate = self
        navigationController?.pushViewController(memberDetailVC, animated: true)
    }
}

extension MembersCoordinator: MemberDetailViewModelDelegate {
    func memberDetailViewModelDidRequestCurrencyTable(for member: Member) {
        let currencyTableVC = builder.buildCurrencyTableViewController(with: member)
        currencyTableVC.viewModel?.delegate = self
        navigationController?.pushViewController(currencyTableVC, animated: true)
    }
}

extension MembersCoordinator: CurrencyTableViewModelDelegate {
    func currencyTableViewModelDidRequestExchange(_ viewModel: CurrencyTabelViewModel, with exchangeRate: ExchangeRate?) {
        let exchangeRateVC = builder.buildExchangeRateViewController(with: exchangeRate)
        exchangeRateVC.viewModel?.onDissmis = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        exchangeRateVC.viewModel?.errorDelegate = self
        exchangeRateVC.viewModel?.delegate = viewModel
        navigationController?.pushViewController(exchangeRateVC, animated: true)
    }
}

extension MembersCoordinator: ExchangeRateViewModelErrorDelegate {
    func exchangeRateViewModel(didFailWith errorMessage: String) {
        UIAlertController.showAlert(withTitle: "", message: errorMessage)
    }
}
