//
//  MemberViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 13/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MemberViewModelDelegate: class {
    func memberViewModel(didCreate member: Member)
}

protocol MemberViewModelErrorDelegate: class {
    func memberViewModel(didFailWith errorMessage: String)
}

protocol MemberViewModel: class {
    var delegate: MemberViewModelDelegate? { get set }
    var errorDelegate: MemberViewModelErrorDelegate? { get set }

    var namePlaceholder: String { get }
    var surnamePlaceholder: String { get }
    var emailPlaceholder: String { get }
    var doneTitle: String { get }

    var addAction: PublishRelay<Void> { get }
    var name: BehaviorRelay<String?> { get }
    var surname: BehaviorRelay<String?> { get }
    var email: BehaviorRelay<String?> { get }

    var onDissmis: (() -> Void)? { get set }
}

final class MemberViewModelImp: MemberViewModel {

    // MARK: - Constants view elements

    let namePlaceholder: String = "name".localized
    let surnamePlaceholder: String = "surname".localized
    let emailPlaceholder: String = "email".localized
    let doneTitle: String = "done".localized

    // MARK: - Observers

    let addAction: PublishRelay<Void> = PublishRelay()
    let name: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let surname: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let email: BehaviorRelay<String?> = BehaviorRelay(value: "")
    private let disposeBag = DisposeBag()

    // MARK: - Varaibles

    var onDissmis: (() -> Void)?
    private let autoincrementer: Autoincrementer

    // MARK: - Delegate

    weak var delegate: MemberViewModelDelegate?
    weak var errorDelegate: MemberViewModelErrorDelegate?

    // MARK: - Initializer

    init(autoincrementer: Autoincrementer) {
        self.autoincrementer = autoincrementer
        setupObservers()
    }

    // MARK: - Main

    private func createMemberIfPossible() -> Member? {
        guard let name = self.name.value,
            let surname = self.surname.value,
            name != "", surname != "" else {
                errorDelegate?.memberViewModel(didFailWith: "empty_fields_message".localized)
                return nil
        }

        let id = autoincrementer.getNext()

        return Member(id: id, name: name, surname: surname,
                      email: self.email.value)
    }

    // MARK: - Setup

    private func setupObservers() {
        addAction.subscribe(onNext: { [weak self] in
            guard let member = self?.createMemberIfPossible() else { return }
            self?.delegate?.memberViewModel(didCreate: member)
            self?.onDissmis?()
        }).disposed(by: disposeBag)
    }
}
