//
//  ExpenseDetailViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ExpenseDetailViewModelDelegate: class {
    func expenseDetailViewModelDidRequestBillDetail(for items: [BillItem])
    func expenseDetailViewModelDidRequestEditExpense(for expense: Expense)
}

protocol ExpenseDetailViewModel: class {

    var delegate: ExpenseDetailViewModelDelegate? { get set }

    var descriptionTitle: String { get }
    var amountTitle: String { get }
    var dateTitle: String { get }
    var payerTitle: String { get }
    var contributorsTitle: String { get }
    var editTitle: String { get }
    var billAsset: String { get }

    var billDetailAction: PublishRelay<Void> { get }
    var editAction: PublishRelay<Void> { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func shouldBillDetailBeVisible() -> Bool
}

final class ExpenseDetailViewModelImp: ExpenseDetailViewModel {

    // MARK: - View's componenets

    let descriptionTitle: String
    var amountTitle: String
    let dateTitle: String
    let payerTitle: String
    let contributorsTitle: String
    let editTitle: String = "edit".localized
    let billAsset: String = "paragon"
    let billDetailAction = PublishRelay<Void>()
    let editAction = PublishRelay<Void>()
    let viewDescription = BehaviorRelay<Void>(value: ())

    // MARK: - Variables

    private let expense: Expense
    private let groupCurrency: Currency
    private let disposeBag = DisposeBag()

    weak var delegate: ExpenseDetailViewModelDelegate?

    // MARK: - Initializer

    init(expense: Expense, groupCurrency: Currency) {
        self.descriptionTitle = expense.description
        let amountString = "amount_summary".localized + String(format: "%.2f", expense.amount)
        self.amountTitle = amountString
        if let tip = expense.tip {
            let tipString = String(format: "%.2f", tip)
            amountTitle += " + " + "tip_summary".localized + " \(tipString) "
        }
        amountTitle += expense.currency.code
        self.dateTitle = expense.date.string()
        let payerString = "payer_summary".localized + " " + expense.payer.name + " " + expense.payer.surname
        self.payerTitle = payerString
        self.contributorsTitle = "contributors".localized
        self.expense = expense
        self.groupCurrency = groupCurrency
        setupBinding()
    }

    func shouldBillDetailBeVisible() -> Bool {
        return !expense.items.isEmpty
    }

    // MARK: - Table View methods

    func numberOfRows() -> Int {
        return expense.contributions.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return convertToCellViewModel(contribution:
            expense.contributions[indexPath.row])
    }

    func replaceExpense(with expense: Expense) {

    }

    private func convertToCellViewModel(contribution: Contribution) -> SystemTableCellViewModel {
        let title = "\(contribution.member.name) \(contribution.member.surname)"
        let detailTitle = "\(String(format: "%.2f", contribution.value)) \(groupCurrency.code)"
        return SystemTableCellViewModelImp(title: title,
                                           detailTitle: detailTitle)
    }

    private func setupBinding() {
        billDetailAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let items = self.expense.items
            self.delegate?.expenseDetailViewModelDidRequestBillDetail(for: items)
        }).disposed(by: disposeBag)
        editAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.expenseDetailViewModelDidRequestEditExpense(for: self.expense)
        }).disposed(by: disposeBag)
    }
}


