//
//  GroupsViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

final class GroupsViewController: QuotaViewController {

    // MARK: - Views

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(SystemTableCellView.self)
        return tableView
    }()

    private lazy var insertButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(insertTapped), for: .touchUpInside)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    // MARK: - Variables

    var viewModel: GroupsViewModel? {
        didSet {
            setupBinding()
            updateView()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigationBar()
        setupAppearnce()
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

    private func setupAppearnce() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: insertButton)
        navigationItem.title = viewModel?.title
        navigationController?.navigationBar.prefersLargeTitles = true
        let font = Fonter.font(size: 28, weight: .semiBold)
        let atributes = [NSAttributedString.Key.font:font,
                         NSAttributedString.Key.foregroundColor:UIColor.teal]
        navigationController?.navigationBar.largeTitleTextAttributes = atributes
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

// MARK: - Table View
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SVProgressHUD.show()
        viewModel?.selectedRowAt(indexPath)
    }
}
