//
//  DateTextFieldViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol DateTextFieldViewModel {
    var placeholder: String { get }
    var defaultValue: String? { get }
    var text: BehaviorRelay<String?> { get }
    var date: BehaviorRelay<Date?> { get }
}

final class DateTextFieldViewModelImp: DateTextFieldViewModel {

    private let disposeBag = DisposeBag()

    var defaultValue: String?
    let placeholder: String = "date".localized
    let text: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let date: BehaviorRelay<Date?>

    init(date: Date? = Date()) {
        self.date = BehaviorRelay(value: date)
        self.defaultValue = ""
        self.defaultValue = string(from: date) ?? ""
        setupBinding()
    }

    private func setupBinding() {
        date.map { [weak self] date in
            return self?.string(from: date)
            }.bind(to: text).disposed(by: disposeBag)
    }

    private func string(from date: Date?) -> String? {
        guard let date = date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
}
