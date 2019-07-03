//
//  ExchangeRateViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 29/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ExchangeRateViewController: QuotaViewController {

    // MARK: - Views

    private let ownedTextField: CurrencyTextField = {
        let textField = CurrencyTextField()
        textField.underlineStyle()
        return textField
    }()

    private let rateTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let orderdTextField: CurrencyTextField = {
        let textField = CurrencyTextField()
        textField.underlineStyle()
        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    // MARK: - Variables

    var viewModel: ExchangeRateViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLayout()
        setupAppearance()
        setupNavigationBar()
    }

    // MARK: - Event handlers

    @objc
    private func doneTapped() {
        viewModel?.doneTapped()
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        ownedTextField.viewModel = viewModel.ownedCurrencyViewModel
        orderdTextField.viewModel = viewModel.orderedCurrencyViewModel
        rateTextField.placeholder = viewModel.rateTitle
        doneButton.setTitle(viewModel.doneTitle, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        rateTextField.rx.text
            .bind(to: viewModel.rate)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: doneButton),
                                         animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(stackView)

        [ownedTextField,
         rateTextField,
         orderdTextField].forEach(stackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.height.equalTo(200)
        }
    }
}
