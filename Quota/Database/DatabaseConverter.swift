//
//  DatabaseConverter.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol DatabaseConverter {
     func convertToGroup(_ groupMO: GroupManagedObject) -> Group?
}

final class DatabaseConverterImp: DatabaseConverter {

    private let currencies: [Currency]

    init(currencies: [Currency]) {
        self.currencies = currencies
    }

    func convertToGroup(_ groupMO: GroupManagedObject) -> Group? {
        guard let currency = currencyFor(code: groupMO.currencyCode ?? ""),
            let membersMO = groupMO.members,
            let expensesMO = groupMO.expenses else { return nil }
        let members = Array(membersMO).map { convertToMember($0 as! MemberManagedObject) }
        let expenses = Array(expensesMO).map { convertToExpense($0 as! ExpenseManagedObject) }
        let group = Group(id: Int(groupMO.id), name: groupMO.name ?? "",
                          currency: currency, members: members, expenses: expenses)
        return group
    }

    func convertToMember(_ memberMO: MemberManagedObject) -> Member {
        guard let ratesMO = memberMO.exchangeRates else { fatalError() }
        let rates = Array(ratesMO).map { convertToExchangeRate($0 as! ExchangeRateManagedObject)  }
        let member = Member(id: Int(memberMO.id), name: memberMO.name ?? "",
                            surname: memberMO.surname ?? "",
                            email: memberMO.email, totalBalance: memberMO.totalBalance,
                            exchangeRates: rates)
        return member
    }

    func convertToExpense(_ expenseMO: ExpenseManagedObject) -> Expense {
        guard let currency = currencyFor(code: expenseMO.currencyCode ?? ""),
            let payerMO = expenseMO.payer,
            let borrowersMO = expenseMO.borrowers,
            let contributionsMO = expenseMO.contributions,
            let itemsMO = expenseMO.items else { fatalError() }

        let description = expenseMO.expenseDescription ?? ""
        let amount = expenseMO.amount
        let date = expenseMO.date ?? Date()
        let tip = expenseMO.tip != nil ? Double(truncating: expenseMO.tip!) : nil
        let payer = convertToMember(payerMO)
        let borrowers = Array(borrowersMO).map { convertToMember($0 as! MemberManagedObject) }
        let contributions = Array(contributionsMO).map { convertToContribution($0 as! ContributionManagedObject) }
        let items = Array(itemsMO).map{ convertToItem($0 as! BillItemManagedObject) }
        let expense = Expense(description: description, amount: amount,
                              tip: tip, date: date,
                              currency: currency, payer: payer,
                              borrowers: borrowers,
                              contributions: contributions,
                              items: items)
        return expense
    }

    func convertToContribution(_ contributionMO: ContributionManagedObject) -> Contribution {
        guard let memberMO = contributionMO.member else { fatalError() }
        let member = convertToMember(memberMO)
        return Contribution(member: member, value: contributionMO.value)
    }

    func convertToExchangeRate(_ rateMO: ExchangeRateManagedObject) -> ExchangeRate {
        guard let orderedCurrencyCode = rateMO.orderedCurrencyCode,
            let ownedCurrencyCode = rateMO.ownedCurrencyCode,
            let orderedCurrency = currencyFor(code: orderedCurrencyCode),
            let ownedCurrency = currencyFor(code: ownedCurrencyCode) else { fatalError() }
        return ExchangeRate(ownedCurrency: ownedCurrency,
                            orderedCurrency: orderedCurrency,
                            rate: rateMO.rate)
    }

    func convertToItem(_ itemMO: BillItemManagedObject) -> BillItem {
        guard let description = itemMO.info else { fatalError() }
        return BillItem(description: description, amount: itemMO.amount)
    }

    private func currencyFor(code: String) -> Currency? {
        return currencies.first(where: { $0.code == code })
    }

}
