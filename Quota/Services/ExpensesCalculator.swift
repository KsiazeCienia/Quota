//
//  ExpensesCalculator.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

typealias ResultBlock<T> = (Result<T>) -> ()

enum Result<T> {
    case Error(error : Error)
    case Success(result : T)
}

protocol ExpensesCalculator {
    func updateBalances(for group: Group, with expense: Expense)
    func debtBetween(payer: Member, borrower: Member, in group: Group) -> Double
    func normalizeExpense(_ expense: Expense, to currency: Currency,
                          completion: @escaping ResultBlock<Expense>)
    func normaliceExpense(_ expense: Expense, to currency: Currency,
                          with rate: Double)  -> Expense
    func removeExpense(_ expense: Expense, from group: Group)
}

final class ExpensesCalculatorImp: ExpensesCalculator  {

    func updateBalances(for group: Group, with expense: Expense) {

        group.expenses.append(expense)

        guard let payer = group.members.first(where: { $0.id == expense.payer.id }) else { return }
        payer.totalBalance += expense.contributions.map{ $0.value }.reduce(0, { $0 + $1 })
        DatabaseManager.shared.updateMember(payer)

        for contribution in expense.contributions {
            contribution.member.totalBalance -= contribution.value
            DatabaseManager.shared.updateMember(contribution.member)
        }
    }

    func removeExpense(_ expense: Expense, from group: Group) {

        guard let payer = group.members.first(where: { $0.id == expense.payer.id }) else { return }
        payer.totalBalance -= expense.contributions.map{ $0.value }.reduce(0, { $0 + $1 })

        for contribution in expense.contributions {
            contribution.member.totalBalance += contribution.value
            DatabaseManager.shared.updateMember(contribution.member)
        }
    }

    func debtBetween(payer: Member, borrower: Member, in group: Group) -> Double {
        let payerExpenses = group.expenses.filter{ $0.payer.id == payer.id }
        let contribution = payerExpenses.flatMap{ $0.contributions }
        let otherMemberDebts = contribution.filter{ $0.member.id == borrower.id }
        let totalDebt = otherMemberDebts.map{ $0.value }.reduce(0, { $0 + $1 })

        return totalDebt
    }

    func normalizeExpense(_ expense: Expense, to currency: Currency,
                          completion: @escaping ResultBlock<Expense>) {
        var apiContribution: [Contribution] = []
        for borrower in expense.borrowers {
            if let exchangeRate = borrower.hasExchangeRate(owned: expense.currency, ordered: currency) {
                let borrowerContribution = expense.contributions
                    .first { $0.member.id == borrower.id }!
                borrowerContribution.value *= exchangeRate.rate
            } else {
                let contribution = expense.contributions
                    .first { $0.member.id == borrower.id }!
                apiContribution.append(contribution)
            }
        }

        if !apiContribution.isEmpty {
            let url = createCurrencyURL(for: expense.currency,
                                        ordered: currency,
                                        in: expense.date)

            getRate(for: url) { [weak self] result in
                switch result {
                case .Error(error: let error):
                    completion(Result.Error(error: error))
                case .Success(result: let data):
                    if let rate = self?.parseRate(data: data) {
                        apiContribution.forEach {
                            $0.value *= rate
                        }
                        completion(Result.Success(result: expense))
                    }
                }
            }
        } else {
            completion(Result.Success(result: expense))
        }
    }

    func normaliceExpense(_ expense: Expense, to currency: Currency,
                          with rate: Double) -> Expense {
        for borrower in expense.borrowers {
            if let exchangeRate = borrower.hasExchangeRate(owned: expense.currency, ordered: currency) {
                let borrowerContribution = expense.contributions
                    .first { $0.member.id == borrower.id }!
                borrowerContribution.value *= exchangeRate.rate
            } else {
                let contribution = expense.contributions
                    .first { $0.member.id == borrower.id }!
                contribution.value *= rate
            }
        }
        return expense
    }

    private func getRate(for url: URL, completion: @escaping ResultBlock<Data>) {
        URLSession(configuration: URLSessionConfiguration.default)
            .dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(Result.Error(error: error))
                    }
                }
                if let data = data {
                    DispatchQueue.main.async {
                        completion(Result.Success(result: data))
                    }
                }
            }).resume()
    }

    private func createCurrencyURL(for owned: Currency, ordered: Currency, in date: Date) -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let urlString = "https://api.exchangeratesapi.io/\(dateString)?" +
        "symbols=\(ordered.code)&base=\(owned.code)"
        return URL(string: urlString)!
    }

    private func parseRate(data: Data) -> Double? {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String: Any] {
            if let rates = dict["rates"] as? [String: Double] {
                 return rates.first?.value
            }
        }
        return nil
    }
}
