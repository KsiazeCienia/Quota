//
//  AmountViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AmountSplitViewController: UIViewController {

    // MARK: - Views

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font (size: 16, weight: .semiBold)
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 60
        tableView.register(AmountSplitCellView.self)
        return tableView
    }()

    // MARK: - Variables

    var viewModel: AmountSplitViewModel? {
        didSet {
            tableView.reloadData()
            setupBinding()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setupApperance()
        setupLayout()
    }

    // MARK: - Setup

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.balance
            .map { "left".localized + String(format: "%.2f", $0) }
            .bind(to: balanceLabel.rx.text)
            .disposed(by: disposeBag)
        keyboardWillShow().subscribe(onNext: { [weak self] height in
            self?.tableView.contentInset = UIEdgeInsets(top: 0,
                                                        left: 0,
                                                        bottom: height,
                                                        right: 0)
        }).disposed(by: disposeBag)
        keyboardWillHide().subscribe(onNext: { [weak self] height in
            self?.tableView.contentInset = .zero
        }).disposed(by: disposeBag)
    }

    private func setupApperance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        [tableView, balanceLabel].forEach(view.addSubview)

        balanceLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.height.equalTo(40)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(balanceLabel.snp.bottom).offset(15)
        }
    }
}

extension AmountSplitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AmountSplitCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}
