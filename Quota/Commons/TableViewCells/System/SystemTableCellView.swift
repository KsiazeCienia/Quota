//
//  SystemTableCellView.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SystemTableCellView: UITableViewCell {

    // MARK: - Variables

    var viewModel: SystemTableCellViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    // MARK: - Cell's life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        disposeBag = DisposeBag()
        viewModel = nil
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }
        textLabel?.text = viewModel.title
        detailTextLabel?.text = viewModel.detailTitle
        accessoryType = viewModel.accessoryType
    }

    // MARK: - Setup

    private func setupCell() {
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
        textLabel?.font = Fonter.font(size: 16, weight: .semiBold)
        textLabel?.textColor = .aztec
        detailTextLabel?.font = Fonter.font(size: 16, weight: .regular)
        detailTextLabel?.textColor = .alto
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        if viewModel.isSelectable {
            viewModel.isSelected.subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.accessoryType = value ? viewModel.accessoryType : .none
            }).disposed(by: disposeBag)
        }
    }
}
