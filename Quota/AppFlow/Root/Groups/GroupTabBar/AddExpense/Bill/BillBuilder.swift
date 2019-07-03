//
//  BillBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 05/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol BillBuilder: class {
    func buildBill() -> BillViewController
    func buildItems(with items: [BillItem]) -> ItemsViewController
    func buildItemDetail(with item: BillItem) -> ItemDetailViewController
}

final class BillBuilderImp: BillBuilder {

    func buildBill() -> BillViewController {
        let controller = BillViewController()
        let recognizer = BillRecognizerImp()
        controller.viewModel = BillViewModelImp(billRecognizer: recognizer)
        return controller
    }

    func buildItems(with items: [BillItem]) -> ItemsViewController {
        let controller = ItemsViewController()
        controller.viewModel = ItemsViewModelImp(items: items)
        return controller
    }

    func buildItemDetail(with item: BillItem) -> ItemDetailViewController {
        let controller = ItemDetailViewController()
        controller.viewModel = ItemDetailViewModelImp(item: item)
        return controller
    }
}
