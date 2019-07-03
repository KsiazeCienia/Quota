//
//  ProportionalSplitViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProportionalSplitViewController: UIViewController {

    // MARK: - Views

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.register(ProportionalSplitCellView.self)
        return tableView
    }()

    // MARK: - Variables

    var viewModel: ProportionalSplitViewModel? {
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
        view.backgroundColor = .red
    }

    private func setupLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ProportionalSplitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ProportionalSplitCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}
