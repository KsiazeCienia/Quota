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

final class ExpensesViewController: QuotaViewController {

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

    private let dissmisButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    // MARK: - Variables

    var viewModel: ExpensesViewModel? {
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
        setupLayout()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        let image = UIImage(named: viewModel.dissmisAsset)!.withRenderingMode(.alwaysOriginal)
        dissmisButton.setImage(image, for: .normal)
        navigationItem.title = viewModel.title
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.reloadData.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        dissmisButton.rx.tap
            .bind(to: viewModel.dismissAction)
            .disposed(by: disposeBag)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: dissmisButton),
                                        animated: false)
        let font = Fonter.font(size: 16, weight: .semiBold)
        let atributes = [NSAttributedString.Key.font:font,
                         NSAttributedString.Key.foregroundColor:UIColor.alto]
        navigationController?.navigationBar.titleTextAttributes = atributes
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

// MARK: - UITableView
extension ExpensesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectedRow(at: indexPath)
    }
}
