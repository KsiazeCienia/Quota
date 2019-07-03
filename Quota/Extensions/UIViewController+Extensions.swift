//
//  UIViewController+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 12/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//MARK:- Hide keyboard when tapped around
extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {

    func keyboardWillShow() -> Observable<CGFloat> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        }
    }

    func keyboardWillHide() -> Observable<CGFloat> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        }
    }
}
