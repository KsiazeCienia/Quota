//
//  SelectableListViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 01/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SelectableListViewController: QuotaViewController {

    // MARK: - Views

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SystemTableCellView.self)
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Variables

    var viewModel: SelectableListViewModel? {
        didSet {
            tableView.reloadData()
            updateView()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAppearance()
    }

    // MARK: - Event handlers

    @objc
    private func doneTapped() {
        viewModel?.doneTapped()
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        if viewModel.isDoneVisible { setupNavigationBar() }
        doneButton.setTitle(viewModel.doneTitle, for: .normal)
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: doneButton), animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

    }
}

// MARK: - UITableView
extension SelectableListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selected(cellAt: indexPath)
    }
}
