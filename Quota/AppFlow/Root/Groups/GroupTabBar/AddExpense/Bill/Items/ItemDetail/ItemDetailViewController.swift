//
//  ItemDetailViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 05/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ItemDetailViewController: QuotaViewController {

    // MARK: - Views

    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        return textField
    }()

    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    // MARK: - Variables

    var viewModel: ItemDetailViewModel? {
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

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        descriptionTextField.text = viewModel.descriptionTitle
        amountTextField.text = viewModel.amountTitle
        saveButton.setTitle(viewModel.saveTitle, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        saveButton.rx.tap
            .bind(to: viewModel.saveAction)
            .disposed(by: disposeBag)

        descriptionTextField.rx.text
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)

        amountTextField.rx.text
            .bind(to: viewModel.amount)
            .disposed(by: disposeBag)

    }


    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: saveButton),
                                         animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(stackView)

        [descriptionTextField,
         amountTextField].forEach(stackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
                $0.height.equalTo(100)
        }
    }
}
