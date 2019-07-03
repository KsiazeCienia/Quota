//
//  MemberViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 13/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MemberViewController: QuotaViewController {

    // MARK: - Views

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        return textField
    }()

    private let surnameTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        return textField
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.underlineStyle()
        return textField
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.roundButtonStyle()
        return button
    }()

    // MARK: - Variables

    var viewModel: MemberViewModel? {
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
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }
        nameTextField.placeholder = viewModel.namePlaceholder
        surnameTextField.placeholder = viewModel.surnamePlaceholder
        emailTextField.placeholder = viewModel.emailPlaceholder
        doneButton.setTitle(viewModel.doneTitle, for: .normal)
    }

    // MARK: - Setup

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(stackView)
        view.addSubview(doneButton)
        [nameTextField,
         surnameTextField,
         emailTextField].forEach(stackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(180)
        }

        doneButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(40)
            $0.top.equalTo(stackView.snp.bottom).offset(20)
        }
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        nameTextField.rx.text
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)

        surnameTextField.rx.text
            .bind(to: viewModel.surname)
            .disposed(by: disposeBag)

        emailTextField.rx.text
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)

        doneButton.rx.tap
            .bind(to: viewModel.addAction)
            .disposed(by: disposeBag)
    }
}
