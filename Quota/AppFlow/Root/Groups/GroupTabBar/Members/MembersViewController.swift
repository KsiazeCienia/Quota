//
//  MembersViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI

final class MembersViewController: QuotaViewController, Refreshable {

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

    private lazy var sendSummaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self,
                         action: #selector(sendSummaryTapped),
                         for: .touchUpInside)
        return button
    }()

    // MARK: - Varaiables

    var viewModel: MembersViewModel? {
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

    // MARK: - Event handlers

    @objc
    private func sendSummaryTapped() {
        guard let viewModel = viewModel else { return }
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(viewModel.subjectTitle)
            if let data = viewModel.attachmentData() {
                mail.addAttachmentData(data, mimeType: "application/json",
                                       fileName: viewModel.fileName)
            }
            present(mail, animated: true)
        }
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        let image = UIImage(named: viewModel.dissmisAsset)!.withRenderingMode(.alwaysOriginal)
        dissmisButton.setImage(image, for: .normal)
        let exportImage = UIImage(named: viewModel.exposrtAsset)!.withRenderingMode(.alwaysOriginal)
        sendSummaryButton.setImage(exportImage, for: .normal)
        navigationItem.title = viewModel.title
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

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
        navigationItem.setRightBarButton(UIBarButtonItem(customView:  sendSummaryButton), animated: true)
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

    func refresh() {
        tableView.reloadData()
    }
}

// MARK: - UITableView
extension MembersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SystemTableCellView = tableView.dequeueReusableCell(SystemTableCellView.self, for: indexPath)
        cell.viewModel = viewModel?.cellViewModel(forRowAt: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selected(rowAt: indexPath)
    }
}

extension MembersViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
