//
//  SelectableListViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 01/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


protocol SelectableListViewModelDelegate: class {
    func selectableListViewModel(_ viewModel: SelectableListViewModel,
                                 members: [Member])
}

protocol SelectableListViewModel: class {

    var delegate: SelectableListViewModelDelegate? { get set }
    var onDissmis: (() -> Void)? { get set }

    var isDoneVisible: Bool { get }
    var doneTitle: String { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func selected(cellAt indexPath: IndexPath)
    func doneTapped()
}

extension SelectableListViewModel {
    func doneTapped() {
        fatalError("doneTapped not implemnted")
    }

    var doneTitle: String {
        return "done".localized
    }
}
