//
//  UIAlertController+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 09/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func showAlert(withTitle title: String?, message: String? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.show()
    }

    func show() {
        present(animated: true, completion: nil)
    }

    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }

    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else {
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion)
            }
        }
    }
}
