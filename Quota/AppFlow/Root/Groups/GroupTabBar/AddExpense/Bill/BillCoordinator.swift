//
//  BillCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 05/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol BillCoordinatorDelegate: class {
    func closeBillCoordinator(with items: [BillItem]?)
}

final class BillCoordinator: Coordinator {

    var rootCoordinator: RootCoordinator?
    var navigationController: UINavigationController?
    var root: UIViewController?

    weak var delegate: BillCoordinatorDelegate?

    private let builder: BillBuilder
    private let items: [BillItem]?

    init(builder: BillBuilder, items: [BillItem]? = nil) {
        self.builder = builder
        self.items = items
    }

    func start() {
        var rootVC: UIViewController
        if let items = items  {
            let itemsVC = builder.buildItems(with: items)
            itemsVC.viewModel?.delegate = self
            itemsVC.viewModel?.isEditingEnabled = false
            rootVC = itemsVC
        } else {
            let billVC = builder.buildBill()
            billVC.viewModel?.delegate = self
            rootVC = billVC
        }
        navigationController = UINavigationController(rootViewController: rootVC)
        root = navigationController
    }
}



extension BillCoordinator: BillViewModelDelegate {
    func billViewModel(didCreate items: [BillItem]) {
        let itemsVC = builder.buildItems(with: items)
        itemsVC.viewModel?.delegate = self
        navigationController?.pushViewController(itemsVC, animated: true)
    }

    func billViewModelRequestDismiss() {
        delegate?.closeBillCoordinator(with: nil)
    }
}

extension BillCoordinator: ItemsViewModelDelegate {
    func itemsViewModel(didCreate items: [BillItem]) {
        delegate?.closeBillCoordinator(with: items)
    }

    func itemsViewModel(_ viewModel: ItemsViewModel ,didSelect item: BillItem) {
        let itemDetailVC = builder.buildItemDetail(with: item)
        itemDetailVC.viewModel?.delegate = viewModel
        itemDetailVC.viewModel?.onDismiss = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(itemDetailVC, animated: true)
    }
}
