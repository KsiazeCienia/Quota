//
//  CurrencyTextField.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyTextField: UITextField {

    // MARK: - Views

    private lazy var currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    // MARK: - Variables

    var viewModel: CurrencyTextFieldViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        placeholder = viewModel.placeholderTitle
        text = viewModel.selectedCurrency.value?.code
        let image = UIImage(named: viewModel.expandAsset)
        rightView = UIImageView(image: image)
    }

    private func setupTextField() {
        inputView = currencyPicker
        rightViewMode = .always
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }
        viewModel.reloadData
            .subscribe(onNext: { [weak self] in
                self?.currencyPicker.reloadAllComponents()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Picker
extension CurrencyTextField: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.numberOfRows() ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.title(forRow: row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        text = viewModel?.title(forRow: row)
        viewModel?.selected(rowAt: row)
    }
}


