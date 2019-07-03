//
//  QuotaViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 08/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

class QuotaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "backButton").withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "backButton").withRenderingMode(.alwaysOriginal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
