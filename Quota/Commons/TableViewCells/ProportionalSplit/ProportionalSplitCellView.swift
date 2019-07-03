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

final class ProportionalSplitCellView: UITableViewCell {

    // MARK: - Views

    private let shareTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        textField.rightViewMode = .always
        textField.keyboardType = .numberPad
        return textField
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)
        return label
    }()

    private let contributionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Fonter.font(size: 16, weight: .semiBold)
        return label
    }()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Variables

    var viewModel: ProportionalSplitCellViewModel? {
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

        shareTextField.rx.text
            .bind(to: viewModel.shareUnits)
            .disposed(by: disposeBag)

        viewModel.memberContribution
            .bind(to: contributionLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func updateView() {
        nameLabel.text = viewModel?.nameTitle
        shareTextField.text = viewModel?.shareUnits.value
        let shareLabel = UILabel()
        shareLabel.translatesAutoresizingMaskIntoConstraints = false
        shareLabel.font = Fonter.font(size: 14, weight: .semiBold)
        shareLabel.textColor = .alto
        shareLabel.text = viewModel?.shareTitle
        shareTextField.rightView = shareLabel
    }

    private func setupLayout() {
        addSubview(mainStackView)

        [leftStackView, contributionLabel]
            .forEach(mainStackView.addArrangedSubview)

        [nameLabel, shareTextField]
            .forEach(leftStackView.addArrangedSubview)

        mainStackView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
