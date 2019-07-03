//
//  SystemTableCellViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SystemTableCellViewModel {
    var title: String { get }
    var detailTitle: String? { get }
    var accessoryType: UITableViewCell.AccessoryType { get }
    var isSelected: BehaviorRelay<Bool> { get }
    var isSelectable: Bool { get }
}

final class SystemTableCellViewModelImp: SystemTableCellViewModel {

    let title: String
    let detailTitle: String?
    let accessoryType: UITableViewCell.AccessoryType
    let isSelected: BehaviorRelay<Bool>
    let isSelectable: Bool

    init(title: String,
         detailTitle: String? = nil,
         accessoryType: UITableViewCell.AccessoryType = .none,
         isSelected: Bool = false,
         isSelectable: Bool = false) {
        self.title = title
        self.detailTitle = detailTitle
        self.accessoryType = accessoryType
        self.isSelected = BehaviorRelay<Bool>(value: isSelected)
        self.isSelectable = isSelectable
    }
}
