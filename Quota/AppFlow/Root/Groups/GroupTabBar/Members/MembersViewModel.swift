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

protocol Refreshable {
    func refresh()
}

protocol MembersViewModelDelegate: class {
    func membersViewModel(didSelect member: Member)
    func closeMembersFlow()
}

protocol MembersViewModel: class {

    var delegate: MembersViewModelDelegate? { get set }

    var dismissAction: PublishRelay<Void> { get }

    var dissmisAsset: String { get }
    var exposrtAsset: String { get }
    var fileName: String { get }
    var subjectTitle: String { get }
    var title: String { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func selected(rowAt indexPath: IndexPath)
    func attachmentData() -> Data?
}

final class MembersViewModelImp: MembersViewModel {

    let dismissAction = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    let title: String
    let fileName: String = "file_name".localized
    let exposrtAsset: String = "export"
    let subjectTitle: String = "summary_subject_title".localized

    // MARK: - Constants

    private let group: Group
    let dissmisAsset: String = "dismiss"

    // MARK: - Delegate

    weak var delegate: MembersViewModelDelegate?

    // MARK: - Initializer

    init(group: Group) {
        self.group = group
        self.title = group.name
        setupBinding()
    }

    func attachmentData() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(group)
            return jsonData
        } catch {
            print(error)
            return nil
        }
    }

    // MARK: - TableView methods

    func numberOfRows() -> Int {
        return group.members.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return convertToCellData(member: group.members[indexPath.row])
    }

    private func convertToCellData(member: Member) -> SystemTableCellViewModel {
        let memberInfo = member.name.capitalized + " " + member.surname.capitalized
        let balance = String(format: "%.2f", member.totalBalance) + " "
            + group.currency.code
        return SystemTableCellViewModelImp(title: memberInfo,
                                           detailTitle: balance)
    }

    func selected(rowAt indexPath: IndexPath) {
        delegate?.membersViewModel(didSelect: group.members[indexPath.row])
    }

    private func setupBinding() {
        dismissAction.subscribe(onNext: { [weak self] in
            self?.delegate?.closeMembersFlow()
        }).disposed(by: disposeBag)
    }
}
