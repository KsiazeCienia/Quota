//
//  MemberDetailViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 28/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MemberDetailViewModelDelegate: class {
    func memberDetailViewModelDidRequestCurrencyTable(for member: Member)
}

protocol MemberDetailViewModel: class {

    var delegate: MemberDetailViewModelDelegate? { get set }

    var nameTitle: String { get }
    var emailTitle: String? { get }
    var currencyTitle: String { get }
    var totalBalanceTitle: String { get }
    var sendAsset: String { get }
    var subjectTitle: String { get }

    var reloadAction: PublishRelay<Void> { get }
    var currencyTableAction: PublishRelay<Void> { get }

    func numberOfRows() -> Int
    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel
    func memberEmail() -> String?
    func emialText() -> String
}

final class MemberDetailViewModelImp: MemberDetailViewModel {

    // MARK: - View's componenets

    let nameTitle: String
    let emailTitle: String?
    let currencyTitle: String = "currency_table_button_title".localized
    let totalBalanceTitle: String
    let sendAsset: String = "send"
    let subjectTitle: String = "summary_subject_title".localized

    // MARK: - Observers

    let reloadAction = PublishRelay<Void>()
    let currencyTableAction = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Services

    private let expensesCalculator: ExpensesCalculator

    // MARK: - Variables

    private let member: Member
    private let group: Group
    private var debts: [Debt] = []
    private var cellViewModels: [SystemTableCellViewModel] = [] {
        didSet {
            reloadAction.accept(())
        }
    }

    // MARK: - Struct

    struct Debt {
        let memeberInfo: String
        let amount: Double
    }

    // MARK: - Delegate

    weak var delegate: MemberDetailViewModelDelegate?

    // MARK: - Initializer

    init(member: Member, group: Group, expensesCalculator: ExpensesCalculator) {
        self.member = member
        self.nameTitle = member.name + " " + member.surname
        self.emailTitle = member.email
        self.group = group
        self.expensesCalculator = expensesCalculator
        let totalBalanceString = "total_balance".localized
            + String(format: "%.2f", member.totalBalance)
            + group.currency.symbol
        self.totalBalanceTitle = totalBalanceString
        calculateOtherUserDebt()
        setupBinding()
    }

    // MARK: - Table View methods

    func numberOfRows() -> Int {
        return cellViewModels.count
    }

    func cellViewModel(forRowAt indexPath: IndexPath) -> SystemTableCellViewModel {
        return cellViewModels[indexPath.row]
    }

    private func cellViewModel(for member: Member, totalBalance: Double) -> SystemTableCellViewModel {
        let title = member.name + " " + member.surname
        let detailTitle = "\(String(format: "%.2f", totalBalance)) \(group.currency.code) "
        return SystemTableCellViewModelImp(title: title, detailTitle: detailTitle)
    }

    // MARK: - Main

    func memberEmail() -> String? {
        return member.email
    }

    func emialText() -> String {
        return prepareEmailText()
    }

    private func prepareEmailText() -> String {
        var text: String = ""
        for debt in debts {
            var line: String
            if debt.amount < 0 {
                line = "you_are_owed".localized + String(format: "%.2f", abs(debt.amount))
                    + " " + group.currency.code + " "
                    + "to".localized + debt.memeberInfo + "\n"
            } else {
                line = debt.memeberInfo + "owes_you".localized + String(format: "%.2f", debt.amount)
                    + " " + group.currency.code + "\n"
            }
            text += line
        }
        return text
    }

    private func calculateOtherUserDebt() {
        let otherMembers = group.members.filter { $0 !== member }
        for otherMember in otherMembers {

            let otherMemberDebt = expensesCalculator.debtBetween(payer: member,
                                                                 borrower: otherMember,
                                                                 in: group)
            let memberDebt = expensesCalculator.debtBetween(payer: otherMember,
                                                            borrower: member,
                                                            in: group)
            let totalBalance = otherMemberDebt - memberDebt
            let debt = Debt(memeberInfo: otherMember.name + " " + otherMember.surname,
                            amount: totalBalance)
            debts.append(debt)
            cellViewModels.append(cellViewModel(for: otherMember, totalBalance: totalBalance))
        }
    }

    // MARK: - Setup

    private func setupBinding() {
        currencyTableAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.memberDetailViewModelDidRequestCurrencyTable(for: self.member)
        }).disposed(by: disposeBag)
    }
}
