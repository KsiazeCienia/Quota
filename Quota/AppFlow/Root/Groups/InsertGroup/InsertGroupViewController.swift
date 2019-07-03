//
//  InsertGroupsViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 07/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class InsertGroupViewController: QuotaViewController {

    // MARK: - Views

    private let groupNameTextField: UITextField = {
        let textField = UITextField()
        textField.underlineStyle()
        return textField
    }()

    private lazy var currencyTextField: CurrencyTextField = {
        let textField = CurrencyTextField()
        textField.underlineStyle()
        return textField
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(SystemTableCellView.self)
        return tableView
    }()

    private let addUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 18)
        return button
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

    // MARK: - Constants

    private let disposeBag = DisposeBag()

    // MARK: - Variables

    var viewModel: InsertGroupViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLayout()
        setupAppearance()
        setupNavigationBar()
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }
        currencyTextField.viewModel = viewModel.currencyTextFieldViewModel
        groupNameTextField.placeholder = viewModel.groupNamePlaceholder
        addUserButton.setTitle(viewModel.addUserTitle, for: .normal)
        saveButton.setTitle(viewModel.saveTitle, for: .normal)
        let image = UIImage(named: viewModel.dissmisAsset)!.withRenderingMode(.alwaysOriginal)
        cancelButton.setImage(image, for: .normal)
    }

    // MARK: - Setup

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        addUserButton.rx.tap
            .bind(to: viewModel.addUserAction)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind(to: viewModel.saveAction)
            .disposed(by: disposeBag)

        viewModel.reloadAction.asSignal()
            .emit(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        groupNameTextField.rx.text
            .bind(to: viewModel.groupName)
            .disposed(by: disposeBag)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: saveButton),
                                         animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: cancelButton),
                                        animated: true)
    }

    private func setupLayout() {
        [stackView, tableView].forEach(view.addSubview)
        [groupNameTextField, currencyTextField, addUserButton].forEach(stackView.addArrangedSubview)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(180)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(30)
            $0.trailing.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Table view
extension InsertGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInTableView() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}
