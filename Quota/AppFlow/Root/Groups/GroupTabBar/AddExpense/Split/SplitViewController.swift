//
//  SplitPageViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit

final class SplitViewController: QuotaViewController {

    // MARK: - Views

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = .teal
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged),
                                   for: .valueChanged)
        return segmentedControl
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    let proportionalVC = ProportionalSplitViewController()
    let amountVC = AmountSplitViewController()

    // MARK: - Variables

    var viewModel: SplitViewModel? { didSet { updateView() } }

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLayout()
        setupApperance()
        setupNavigationBar()
    }

    // MARK: - Event hanlder

    @objc
    private func segmentedControlChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            amountVC.remove()
            add(proportionalVC, toView: containerView)
        } else {
            proportionalVC.remove()
            add(amountVC, toView: containerView)
        }
    }

    @objc
    private func doneTapped() {
        viewModel?.doneTapped(with: segmentedControl.selectedSegmentIndex)
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        for i in 0 ..< viewModel.segmentTitles.count {
            segmentedControl.insertSegment(withTitle: viewModel.segmentTitles[i],
                                           at: i, animated: true)
            

        }
        proportionalVC.viewModel = viewModel.proportionalSplitViewModel
        amountVC.viewModel = viewModel.amountSplitViewModel
        segmentedControl.selectedSegmentIndex = 0
        add(proportionalVC, toView: containerView)
        doneButton.setTitle(viewModel.doneTitle, for: .normal)
    }

    private func setupNavigationBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(customView: doneButton),
                                         animated: true)
    }

    private func setupLayout() {
        [segmentedControl, containerView].forEach(view.addSubview)

        segmentedControl.snp.makeConstraints {
            $0.width.equalTo(200)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupApperance() {
        view.backgroundColor = .white
    }
}

fileprivate extension UIViewController {

    func add(_ child: UIViewController, toView container: UIView) {
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.view.frame = container.bounds
        addChild(child)
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
