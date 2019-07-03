//
//  SystemTableCellView.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit

class ExchangeRateCellView: UITableViewCell {

    // MARK: - Views

    private let ownedLabel: UILabel = {
        let label = UILabel()
        label.font = Fonter.font(size: 14, weight: .semiBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let rateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonter.font(size: 14, weight: .semiBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .alto
        return label
    }()

    private let orderedLabel: UILabel = {
        let label = UILabel()
        label.font = Fonter.font(size: 14, weight: .semiBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Variables

    var viewModel: ExchangeRateCellViewModel? {
        didSet {
            updateView()
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
        setupLayout()
    }

    // MARK: - Cell's life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }
        ownedLabel.text = viewModel.ownedCurrencyTitle
        orderedLabel.text = viewModel.orderedCurrencyTitle
        rateLabel.text = viewModel.rateTitle
    }

    // MARK: - Setup

    private func setupCell() {
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
    }

    private func setupLayout() {
        addSubview(stackView)

        [ownedLabel, rateLabel,
         orderedLabel].forEach(stackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
