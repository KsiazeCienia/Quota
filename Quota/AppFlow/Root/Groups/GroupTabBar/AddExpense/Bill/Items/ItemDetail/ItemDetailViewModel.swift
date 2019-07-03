//
//  ItemDetailViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 05/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ItemDetailViewModelDelegate: class {
    func itemDetailViewModel(didUpdate item: BillItem)
}

protocol ItemDetailViewModel: class {

    var delegate: ItemDetailViewModelDelegate? { get set }
    var onDismiss: (() -> Void)? { get set }

    var descriptionTitle: String { get }
    var amountTitle: String { get }
    var saveTitle: String { get }

    var saveAction: PublishRelay<Void> { get }
    var description: BehaviorRelay<String?> { get }
    var amount: BehaviorRelay<String?> { get }
}

final class ItemDetailViewModelImp: ItemDetailViewModel {

    weak var delegate: ItemDetailViewModelDelegate?
    var onDismiss: (() -> (Void))?


    let saveAction = PublishRelay<Void>()
    let description: BehaviorRelay<String?>
    let amount: BehaviorRelay<String?>
    private let disposeBag = DisposeBag()
    
    let descriptionTitle: String
    let amountTitle: String
    let saveTitle: String = "save".localized

    init(item: BillItem) {
        self.descriptionTitle = item.description
        self.amountTitle = String(item.amount)
        self.description = BehaviorRelay<String?>(value: item.description)
        self.amount = BehaviorRelay<String?>(value: String(item.amount))
        setupBinding()
    }

    private func updateItemIfPossible() {
        guard let description = description.value,
            let amount = amount.value.commaToDecimal()
            else { return }
        let item = BillItem(description: description,
                            amount: amount)
        delegate?.itemDetailViewModel(didUpdate: item)
        onDismiss?()
    }

    private func setupBinding() {
        saveAction.subscribe(onNext: { [weak self] in
            self?.updateItemIfPossible()
        }).disposed(by: disposeBag)
    }
}
