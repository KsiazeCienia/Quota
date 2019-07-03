//
//  MembersViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ItemsViewModelDelegate: class {
    func itemsViewModel(_ viewModel: ItemsViewModel,didSelect item: BillItem)
    func itemsViewModel(didCreate items: [BillItem])
}

protocol ItemsViewModel: ItemDetailViewModelDelegate {

    var delegate: ItemsViewModelDelegate? { get set }

    var reloadData: PublishRelay<Void> { get }
    var totalAmount: BehaviorRelay<String> { get }
    var doneAction: PublishRelay<Void> { get }
    var isEditingEnabled: Bool { get set }
    var doneTitle: String { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func selected(rowAt indexPath: IndexPath)
    func remove(at indexPath: IndexPath)
}

final class ItemsViewModelImp: ItemsViewModel {

    // MARK: - Constants

    private var items: [BillItem] {
        didSet {
            let total = items.map{ $0.amount }.reduce(0, { $0 + $1 }).rounded(toPlaces: 2)
            let string = "bills_sum".localized + String(total)
            totalAmount.accept(string)
        }
    }
    let reloadData = PublishRelay<Void>()
    let doneAction = PublishRelay<Void>()
    let doneTitle: String = "done".localized
    let totalAmount: BehaviorRelay<String>
    var isEditingEnabled: Bool = true  { didSet { reloadData.accept(()) } }
    private let disposeBag = DisposeBag()
    var selectedItemIndex: Int?

    // MARK: - Delegate

    weak var delegate: ItemsViewModelDelegate?

    // MARK: - Initializer

    init(items: [BillItem]) {
        self.items = items
        let total = items.map{ $0.amount }.reduce(0, { $0 + $1 }).rounded(toPlaces: 2)
        let string = "bills_sum".localized + String(total)
        self.totalAmount = BehaviorRelay<String>(value: string)
        setupBinding()
    }

    // MARK: - TableView methods

    func numberOfRows() -> Int {
        return items.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return convertToCellData(item: items[indexPath.row])
    }

    private func convertToCellData(item: BillItem) -> SystemTableCellViewModel {
        return SystemTableCellViewModelImp(title: item.description,
                                           detailTitle: String(item.amount))
    }

    func selected(rowAt indexPath: IndexPath) {
        if isEditingEnabled {
            selectedItemIndex = indexPath.row
            delegate?.itemsViewModel(self, didSelect: items[indexPath.row])
        }
    }

    func remove(at indexPath: IndexPath) {
        items.remove(at: indexPath.row)
    }

    func itemDetailViewModel(didUpdate item: BillItem) {
        guard let index = selectedItemIndex else { return }
        items.remove(at: index)
        items.insert(item, at: index)
        reloadData.accept(())
    }

    private func setupBinding() {
        doneAction.subscribe(onNext: { [weak self] in
            self?.delegate?.itemsViewModel(didCreate: self?.items ?? [])
        }).disposed(by: disposeBag)
    }
}
