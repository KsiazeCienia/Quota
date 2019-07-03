//
//  ExpensesViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SVProgressHUD

final class ItemsViewController: QuotaViewController {

    // MARK: - Views

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Fonter.font(size: 16, weight: .semiBold)
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SystemTableCellView.self)
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    // MARK: - Variables

    var viewModel: ItemsViewModel? {
        didSet {
            setupBinding()
            updateView()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.dismiss()
        setupAppearance()
        setupLayout()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func updateView() {
        doneButton.setTitle(viewModel?.doneTitle, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.reloadData.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.totalAmount
            .bind(to: totalLabel.rx.text)
            .disposed(by: disposeBag)

        doneButton.rx.tap
            .bind(to: viewModel.doneAction)
            .disposed(by: disposeBag)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: doneButton),
                                         animated: true)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(totalLabel)

        totalLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(40)
        }

        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(totalLabel.snp.bottom).offset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UITableView
extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel?.isEditingEnabled ?? false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.remove(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selected(rowAt: indexPath)
    }
}
