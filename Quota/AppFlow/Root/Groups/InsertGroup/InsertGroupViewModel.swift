//
//  InsertGroupsViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 07/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol InsertGroupViewModelDelegate: class {
    func insertGroupViewModelDidTapCancel()
    func insertGroupViewModel(didCreate group: Group)
    func insertGroupViewModelDidTapAddUser(_ viewModel: InsertGroupViewModel)
    func insertGroupViewModel(didFailWith errorMessage: String)
}

protocol InsertGroupViewModel: MemberViewModelDelegate {

    var delegate: InsertGroupViewModelDelegate? { get set }

    var currencyTextFieldViewModel: CurrencyTextFieldViewModel { get }

    var groupNamePlaceholder: String { get }
    var addUserTitle: String { get }
    var saveTitle: String { get }
    var dissmisAsset: String { get }

    var cancelAction: PublishRelay<Void> { get }
    var saveAction: PublishRelay<Void> { get }
    var addUserAction: PublishRelay<Void> { get }
    var reloadAction: PublishRelay<Void> { get }
    var currency: BehaviorRelay<Currency?> { get }
    var groupName: BehaviorRelay<String?> { get }

    func numberOfRowsInTableView() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
}

final class InsertGroupViewModelImp: InsertGroupViewModel {

    // MARK: - Constants view's componenets

    let groupNamePlaceholder: String = "group_name_placeholder".localized
    let addUserTitle: String = "add_user".localized
    let saveTitle: String = "save".localized
    let dissmisAsset: String = "dismiss"

    let currencyTextFieldViewModel: CurrencyTextFieldViewModel

    // MARK: - Observers

    let cancelAction: PublishRelay<Void> = PublishRelay()
    let saveAction: PublishRelay<Void> = PublishRelay()
    let addUserAction: PublishRelay<Void> = PublishRelay()
    let reloadAction: PublishRelay<Void> = PublishRelay()
    let currency: BehaviorRelay<Currency?> = BehaviorRelay(value: nil)
    let groupName: BehaviorRelay<String?> = BehaviorRelay(value: "")
    private let disposeBag = DisposeBag()

    // MARK: - Delegate

    var delegate: InsertGroupViewModelDelegate?

    // MARK: - Variables

    private var members: [Member] = [] { didSet { reloadAction.accept(()) } }

    private let autoincrementer: Autoincrementer

    // MARK: - Initializer

    init(currencyTextFieldViewModel: CurrencyTextFieldViewModel, autoincrementer: Autoincrementer) {
        self.currencyTextFieldViewModel = currencyTextFieldViewModel
        self.autoincrementer = autoincrementer
        setupObservers()
    }

    // MARK: - Main

    private func saveGroupIfPossible() {
        guard let groupName = groupName.value,
            let currency = currency.value else {
                delegate?.insertGroupViewModel(didFailWith: "empty_fields_message".localized)
                return
        }

        guard members.count > 1 else {
            delegate?.insertGroupViewModel(didFailWith: "not_enough_members".localized)
            return
        }
        
        let group = Group(id: autoincrementer.getNext(),
                          name: groupName,
                          currency: currency,
                          members: members,
                          expenses: [])
        DatabaseManager.shared.saveGroup(group)
        delegate?.insertGroupViewModel(didCreate: group)
    }

    // MARK: - Table view methods

    func numberOfRowsInTableView() -> Int {
        return members.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return convertToCellData(member: members[indexPath.row])
    }

    private func convertToCellData(member: Member) -> SystemTableCellViewModel {
        let memberInfo = member.name.capitalized + " " + member.surname.capitalized
        return SystemTableCellViewModelImp(title: memberInfo,
                                           detailTitle: member.email)
    }

    // MARK: - Setup

    private func setupObservers() {
        currencyTextFieldViewModel
            .selectedCurrency
            .bind(to: currency)
            .disposed(by: disposeBag)
        cancelAction.subscribe(onNext: { [weak self] in
            self?.delegate?.insertGroupViewModelDidTapCancel()
        }).disposed(by: disposeBag)
        saveAction.subscribe(onNext: { [weak self] in
            self?.saveGroupIfPossible()
        }).disposed(by: disposeBag)
        addUserAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.insertGroupViewModelDidTapAddUser(self)
        }).disposed(by: disposeBag)
    }
}

// MARK: - MemberViewModel
extension InsertGroupViewModelImp {
    func memberViewModel(didCreate member: Member) {
        members.append(member)
    }
}
