//
//  ProportionalSplitCellView.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AmountSplitCellView: UITableViewCell {

    // MARK: - Views

    private let contributionTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonter.font(size: 14, weight: .semiBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Variables

    var viewModel: AmountSplitCellViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: - Initializer's

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    // MARK: - Cell's life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        viewModel = nil
    }

    // MARK: - Setup

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        contributionTextField.rx.text
            .bind(to: viewModel.amount)
            .disposed(by: disposeBag)
    }

    private func updateView() {
        nameLabel.text = viewModel?.nameTitle
        contributionTextField.text = viewModel?.initialTitle
        contributionTextField.placeholder = viewModel?.amountPlaceholder
    }

    private func setupLayout() {
        addSubview(mainStackView)

        [nameLabel, contributionTextField]
            .forEach(mainStackView.addArrangedSubview)

        mainStackView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
