//
//  GroupTabBarController.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SVProgressHUD

final class GroupTabBarController: UITabBarController {

    // MARK: - Views

    private let addExpenseButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Variables

    var viewModel: GroupTabBarViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    // MARK: - Constants

    private let disposeBag = DisposeBag()

    // MARK: - Tab bar life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.dismiss()
    }

    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        guard let controllers = viewControllers,
            let viewModel = viewModel else { return }

        let tabBarTitles = [viewModel.expensesTitle,
                            viewModel.membersTitle]
        let tabBarImages = [UIImage(named: viewModel.expensesAsset),
                            UIImage(named: viewModel.membersAsset)]

        for i in 0 ..< controllers.count {
            let tabBarItem = UITabBarItem(title: tabBarTitles[i], image: tabBarImages[i], selectedImage: nil)
            controllers[i].tabBarItem = tabBarItem
        }
        super.setViewControllers(viewControllers, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAddExpenseButton()
        setupTabBar()
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }

        let image = UIImage(named: viewModel.addExpenseTitle)!.withRenderingMode(.alwaysOriginal)
        addExpenseButton.setImage(image, for: .normal)
    }

    // MARK: - Setup

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        addExpenseButton.rx.tap
            .bind(to: viewModel.addExpenseAction)
            .disposed(by: disposeBag)
    }

    private func setupAddExpenseButton() {
        tabBar.insertSubview(addExpenseButton, aboveSubview: tabBar)

        addExpenseButton.snp.makeConstraints {
            $0.height.width.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(tabBar.snp.top)
        }
    }

    private func setupTabBar() {
//        tabBar.backgroundColor = .teal
        tabBar.tintColor = .white
        tabBar.barTintColor = .teal
    }
}
