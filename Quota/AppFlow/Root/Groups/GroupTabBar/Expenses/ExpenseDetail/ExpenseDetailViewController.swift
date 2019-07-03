//
//  ExpenseDetailViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

final class ExpenseDetailViewController: UIViewController {

    // MARK: - Views

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Fonter.font(size: 16, weight: .semiBold)
        return label
    }()

    private let billDetailButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 18, weight: .semiBold)
        label.textAlignment = .center
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)
        label.textColor = .alto
        label.textAlignment = .center
        return label
    }()

    private let payerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)

        label.textAlignment = .center
        return label
    }()

    private let contributorsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)
        label.textColor = .alto
        label.textAlignment = .center
        return label
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

    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Variables

    var viewModel: ExpenseDetailViewModel? {
        didSet {
            updateView()
            tableView.reloadData()
            setupBinding()
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
        descriptionLabel.text = viewModel.descriptionTitle
        amountLabel.text = viewModel.amountTitle
        dateLabel.text = viewModel.dateTitle
        payerLabel.text = viewModel.payerTitle
        contributorsLabel.text = viewModel.contributorsTitle
         let image = UIImage(named: viewModel.billAsset)!.withRenderingMode(.alwaysOriginal)
        billDetailButton.setImage(image, for: .normal)
        editButton.setTitle(viewModel.editTitle, for: .normal)
        billDetailButton.isHidden = !viewModel.shouldBillDetailBeVisible()
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        billDetailButton.rx.tap
            .bind(to: viewModel.billDetailAction)
            .disposed(by: disposeBag)
        editButton.rx.tap
            .bind(to: viewModel.editAction)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        navigationItem.titleView = billDetailButton
        navigationItem.setRightBarButton(UIBarButtonItem(customView: editButton),
                                         animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        [tableView, labelsStackView].forEach(view.addSubview)

        [descriptionLabel, amountLabel,
         dateLabel, payerLabel,
         contributorsLabel].forEach(labelsStackView.addArrangedSubview)

        labelsStackView.snp.makeConstraints {
            $0.leading.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(200)
        }

        tableView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(labelsStackView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension ExpenseDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}
