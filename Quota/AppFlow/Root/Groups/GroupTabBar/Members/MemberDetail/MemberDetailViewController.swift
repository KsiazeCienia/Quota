//
//  MemberViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 28/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MessageUI

final class MemberDetailViewController: QuotaViewController {

    // MARK: - Views

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)
        label.textAlignment = .center
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 16, weight: .semiBold)
        label.textColor = .alto
        label.textAlignment = .center
        return label
    }()

    private let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 18, weight: .semiBold)
        label.textAlignment = .center
        return label
    }()

    private let currencyTableButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
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

    private lazy var emailButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendEmailTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Variables

    var viewModel: MemberDetailViewModel? {
        didSet {
            updateView()
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

    // MARK: - Event handlers

    @objc
    private func sendEmailTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(viewModel?.subjectTitle ?? "")
            mail.setToRecipients([viewModel?.memberEmail() ?? ""])
            mail.setMessageBody(viewModel?.emialText() ?? "", isHTML: false)

            present(mail, animated: true)
        }
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.nameTitle
        emailLabel.text = viewModel.emailTitle
        totalBalanceLabel.text = viewModel.totalBalanceTitle
        currencyTableButton.setTitle(viewModel.currencyTitle, for: .normal)
        let image = UIImage(named: viewModel.sendAsset)!.withRenderingMode(.alwaysOriginal)
        emailButton.setImage(image, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.reloadAction.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        currencyTableButton.rx.tap
            .bind(to: viewModel.currencyTableAction)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        let barButton = UIBarButtonItem(customView: emailButton)
        navigationItem.setRightBarButton(barButton, animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        [tableView, labelsStackView,
         currencyTableButton].forEach(view.addSubview)

        [nameLabel, emailLabel,
         totalBalanceLabel].forEach(labelsStackView.addArrangedSubview)

        labelsStackView.snp.makeConstraints {
            $0.leading.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(140)
        }

        currencyTableButton.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(40)
            $0.top.equalTo(labelsStackView.snp.bottom).offset(15)
        }

        tableView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(currencyTableButton.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension MemberDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }
}

extension MemberDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
