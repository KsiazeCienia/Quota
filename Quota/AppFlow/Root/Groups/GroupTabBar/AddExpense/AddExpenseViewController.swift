//
//  AddExpenseViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddExpenseViewController: QuotaViewController {

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

    private let tipTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let currencyTextField: CurrencyTextField = {
        let textField = CurrencyTextField()
        textField.underlineStyle()
        return textField
    }()

    private let payerButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    private let borrowersButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    private let splitButton: UIButton = {
        let button = UIButton(type: .system)
        button.roundButtonStyle()
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()

    private let horizotnalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()


    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    private let billButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dateTextField: DateTextField = {
        let textField = DateTextField()
        textField.underlineStyle()
        return textField
    }()

    // MARK: - Variables

    var viewModel: AddExpenseViewModel? {
        didSet {
            setupBinding()
            updateView()
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

    // MARK: - Main

    private func showExchangeRateAlert(with message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

        alertController.addTextField { textfield in
            textfield.keyboardType = .decimalPad
        }

        let confirmAction = UIAlertAction(title: "Ok", style: .default) { [weak self] action in
            guard let rate = alertController.textFields?[0].text.commaToDecimal()
                else { return }
            self?.viewModel?.saveExpense(with: rate)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)

        [confirmAction, cancelAction].forEach(alertController.addAction)
        present(alertController, animated: true)
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        currencyTextField.viewModel = viewModel.currencyTextFiledViewModel
        dateTextField.viewModel = viewModel.dateTextFieldViewModel
        descriptionTextField.placeholder = viewModel.descriptionPlaceholder
        amountTextField.placeholder = viewModel.amountPlaceholder
        tipTextField.placeholder = viewModel.tipPlaceholder
        payerButton.setTitle(viewModel.payerTitle, for: .normal)
        borrowersButton.setTitle(viewModel.borrowersTitle, for: .normal)
        splitButton.setTitle(viewModel.splitTitle, for: .normal)
        let image = UIImage(named: viewModel.dissmisAsset)!.withRenderingMode(.alwaysOriginal)
        cancelButton.setImage(image, for: .normal)
        saveButton.setTitle(viewModel.saveTitle, for: .normal)
        if let viewDescription = viewModel.expenseViewDescription {
            descriptionTextField.insertText(viewDescription.description)
            amountTextField.insertText(viewDescription.amount)
            tipTextField.insertText(viewDescription.tip ?? "")
        }
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.billAsset
            .map { UIImage(named: $0)!.withRenderingMode(.alwaysOriginal) }
            .bind(to: billButton.rx.image())
            .disposed(by: disposeBag)

        payerButton.rx.tap
            .bind(to: viewModel.payerAction)
            .disposed(by: disposeBag)

        borrowersButton.rx.tap
            .bind(to: viewModel.borrowersAction)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind(to: viewModel.saveAction)
            .disposed(by: disposeBag)

        billButton.rx.tap
            .bind(to: viewModel.billAction)
            .disposed(by: disposeBag)

        descriptionTextField.rx.text
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)

        amountTextField.rx.text
            .bind(to: viewModel.amount)
            .disposed(by: disposeBag)

        tipTextField.rx.text
            .bind(to: viewModel.tip)
            .disposed(by: disposeBag)

        splitButton.rx.tap
            .bind(to: viewModel.splitAction)
            .disposed(by: disposeBag)

        viewModel.updateAmount
            .bind(to: amountTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.isSplitEnable.subscribe(onNext: { [weak self] isEnable in
            guard let self = self else { return }
            self.splitButton.isEnabled = isEnable
            self.splitButton.backgroundColor = isEnable ? .teal : .alto
        }).disposed(by: disposeBag)

        viewModel.errorAction.subscribe(onNext: { [weak self] message in
            self?.showExchangeRateAlert(with: message)
        }).disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: saveButton),
                                         animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: cancelButton),
                                        animated: true)
        navigationItem.titleView = billButton
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(stackView)
        view.addSubview(splitButton)

        [descriptionTextField,
         horizotnalStackView].forEach(stackView.addArrangedSubview)

        [leftStackView,
         rightStackView].forEach(horizotnalStackView.addArrangedSubview)

        [amountTextField,
        currencyTextField,
        payerButton].forEach(leftStackView.addArrangedSubview)

        [tipTextField,
         dateTextField,
         borrowersButton].forEach(rightStackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.height.equalTo(200)
        }

        splitButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(150)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(stackView.snp.bottom).offset(15)
        }
    }
}
