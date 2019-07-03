//
//  CurrencyTableViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 29/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CurrencyTableViewController: QuotaViewController {

    // MARK: - Views

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 40
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(ExchangeRateCellView.self)
        return tableView
    }()

    private lazy var insertButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(insertTapped), for: .touchUpInside)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    // MARk: - Variables

    var viewModel: CurrencyTabelViewModel? {
        didSet {
            setupBinding()
            updateView()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupLayout()
    }

    // MARK: - Event hanlders

    @objc
    private func insertTapped() {
        viewModel?.insertTapped()
    }

    // MARK: - Setup

    private func updateView() {
        insertButton.setTitle(viewModel?.newTitle, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        viewModel.reloadAction.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: insertButton)

    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension CurrencyTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ExchangeRateCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}
