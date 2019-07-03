//
//  PaddedDateTextFieldCellView.swift
//  Roam
//
//  Created by Marcin Włoczko on 24/10/2018.
//  Copyright © 2018 Prismake. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DateTextField: UITextField {

    // MARK: - Views

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)),
                             for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        return datePicker
    }()

    // MARK: - Variables

    private var disposeBag = DisposeBag()
    var viewModel: DateTextFieldViewModel? { didSet { updateView() } }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }

    @objc private func datePickerValueDidChange(_ sender: UIDatePicker) {
        guard let viewModel = viewModel else { return }
        viewModel.date.accept(sender.date)
    }

    // MARK: - Main

    private func updateView() {
        guard let viewModel = viewModel else { return }
        placeholder = viewModel.placeholder
        text = viewModel.defaultValue
        viewModel.text.asDriver()
            .drive(rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: - Setup

    private func setupTextField() {
        inputView = datePicker
        borderStyle = .roundedRect
    }
}
