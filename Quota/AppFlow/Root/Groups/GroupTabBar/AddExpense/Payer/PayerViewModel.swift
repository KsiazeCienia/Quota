//
//  PayerViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

final class PayerViewModel: SelectableListViewModel {

    // MARK: - Variables

    private let members: [Member]
    private var cellViewModels: [SystemTableCellViewModel] = []
    private let currentPayer: Member?
    let isDoneVisible: Bool = false

    // MARK: - Delegates

    var onDissmis: (() -> Void)?
    var delegate: SelectableListViewModelDelegate?


    // MARK: - Initializer

    init(members: [Member], currentPayer: Member?) {
        self.members = members
        self.currentPayer = currentPayer
        self.cellViewModels = members.map(convertToCellViewModel)
    }

    // MARK: - TableView methods

    func numberOfRows() -> Int {
        return cellViewModels.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func selected(cellAt indexPath: IndexPath) {
        let isSelected = cellViewModels[indexPath.row].isSelected
        isSelected.accept(!isSelected.value)
        delegate?.selectableListViewModel(self, members: [members[indexPath.row]])
        onDissmis?()
    }

    private func convertToCellViewModel(member: Member) -> SystemTableCellViewModel {
        let memberInfo = member.name.capitalized + " " + member.surname.capitalized
        let isSelected = currentPayer != nil ? member.id == currentPayer!.id : false
        return  SystemTableCellViewModelImp(title: memberInfo,
                                            accessoryType: UITableViewCell.AccessoryType.checkmark,
                                            isSelected: isSelected,
                                            isSelectable: true)
    }
}
