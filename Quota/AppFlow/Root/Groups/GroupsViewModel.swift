//
//  GroupsViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GroupsViewModelDelegate: class {
    func groupsViewModelDidTapInsert()
    func groupsViewModel(didSelect group: Group)
}

protocol GroupsViewModel {

    var delegate: GroupsViewModelDelegate? { get set }

    var reloadAction: PublishRelay<Void> { get }
    var title: String { get }
    var newTitle: String { get }

    func insertTapped()
    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func selectedRowAt(_ indexPath: IndexPath)

    func addGroup(_ group: Group)
}

final class GroupsViewModelImp: GroupsViewModel {

    // MARK: - Observers

    let reloadAction: PublishRelay<Void> = PublishRelay()
    let title: String = "groups_title".localized
    let newTitle: String = "new".localized
    private let disposeBag = DisposeBag()

    // MARK: - Delegate

    weak var delegate: GroupsViewModelDelegate?

    // MARK: - Variables

    private var groups: [Group] { didSet { reloadAction.accept(()) } }

    // MARK: - Initializer

    init() {
       self.groups = []
        fetchGroups()
    }

    // MARK: - Main

    func addGroup(_ group: Group) {
        groups.append(group)
    }

    func insertTapped() {
        delegate?.groupsViewModelDidTapInsert()
    }

    private func fetchGroups() {
        let groupsMO: [GroupManagedObject]? = DatabaseManager.shared.fetch()
        let currencyService = CurrencyServiceImp()
        currencyService.fetchCurrencies()
            .subscribe(onNext: { [weak self] currencies in
                guard let accgGoupsMO = groupsMO else { return }
                let converter = DatabaseConverterImp(currencies: currencies)
                self?.groups = accgGoupsMO.map { converter.convertToGroup($0)! }
            }).disposed(by: disposeBag)
    }

    // MARK: - Table view methods

    func numberOfRows() -> Int {
        return groups.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return groups[indexPath.row].toCellData()
    }

    func selectedRowAt(_ indexPath: IndexPath) {
        delegate?.groupsViewModel(didSelect: groups[indexPath.row])
    }
}
