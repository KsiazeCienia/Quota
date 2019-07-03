//
//  BorrowersViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

final class BorrowersViewModel: SelectableListViewModel {

    // MARK: - Vairables

    private let members: [Member]
    private var cellViewModels: [SystemTableCellViewModel] = []
    let isDoneVisible: Bool = true
    private var currentBorrowers: [Member] = []

    // MARK: - Delegates

    var onDissmis: (() -> Void)?
    var delegate: SelectableListViewModelDelegate?

    // MARK: - Initalizer

    init(members: [Member], currentBorrowers: [Member]) {
        self.members = members
        self.currentBorrowers = currentBorrowers
        self.cellViewModels = members.map(convertToCellViewModel)
    }

    // MARK: - Main

    func doneTapped() {
        delegate?.selectableListViewModel(self, members: currentBorrowers)
        onDissmis?()
    }

    // MARK: - TableView methods

    func numberOfRows() -> Int {
        return cellViewModels.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func selected(cellAt indexPath: IndexPath) {
        let selectedMember = members[indexPath.row]
        let isSelected = cellViewModels[indexPath.row].isSelected
        if isSelected.value {
            currentBorrowers = currentBorrowers.filter { $0 !== selectedMember }
            isSelected.accept(false)
        } else {
            currentBorrowers.append(selectedMember)
            isSelected.accept(true)
        }
    }

    private func convertToCellViewModel(member: Member) -> SystemTableCellViewModel {
        let memberInfo = member.name.capitalized + " " + member.surname.capitalized
        let isSelected = currentBorrowers.contains(where: { member.id == $0.id })
        return  SystemTableCellViewModelImp(title: memberInfo,
                                            accessoryType: UITableViewCell.AccessoryType.checkmark,
                                            isSelected: isSelected,
                                            isSelectable: true)
    }
}
