//
//  QuotaTests.swift
//  QuotaTests
//
//  Created by Marcin Włoczko on 03/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import Quota

class QuotaTests: XCTestCase {

    private var group: Group?
    private var currencies: [Currency] = []
    private let calculator = ExpensesCalculatorImp()
    private let member1: Member = {
        return Member(id: 1, name: "Name1", surname: "Surname1", email: nil)
    }()
    private let member2: Member = {
        return Member(id: 2, name: "Name2", surname: "Surname2", email: nil)
    }()
    private let member3: Member = {
        return Member(id: 3, name: "Name3", surname: "Surname3", email: nil)
    }()

    override func setUp() {
        super.setUp()
        let path = Bundle.main.path(forResource: "Currencies",
                                    ofType: "json")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path),
                                options: .mappedIfSafe)
            currencies = try decoder.decode([Currency].self,
                                                from: data)
        } catch {
            print(error)
        }
        group = Group(id: 1, name: "group", currency: currencies[0],
                      members: [member1, member2, member3], expenses: [])
    }

    override func tearDown() {
        super.tearDown()
        group = nil
    }

    func testUpdatingBalances() {
        let expense1 = Expense(description: "desc1", amount: 30, tip: 6, date: Date(),
                              currency: currencies[0], payer: member1,
                              borrowers: [member1, member2, member3],
                              contributions: [
                                Contribution(member: member1, value: 12),
                                Contribution(member: member2, value: 6),
                                Contribution(member: member3, value: 18)], items: [])

        guard let group = group else { return }
        calculator.updateBalances(for: group, with: expense1)
        let member2Debt = calculator.debtBetween(payer: member1, borrower: member2, in: group)
        XCTAssertEqual(member2Debt, 6)
        let member3Debt = calculator.debtBetween(payer: member1, borrower: member3, in: group)
        XCTAssertEqual(member3Debt, 18)
        XCTAssertEqual(member1.totalBalance, 24)
        XCTAssertEqual(member2.totalBalance, -6)
        XCTAssertEqual(member3.totalBalance, -18)

        let expense2 = Expense(description: "desc2", amount: 30, tip: 6, date: Date(),
                               currency: currencies[0], payer: member2,
                               borrowers: [member1, member2, member3],
                               contributions: [
                                Contribution(member: member1, value: 6),
                                Contribution(member: member2, value: 12),
                                Contribution(member: member3, value: 18)], items: [])

        calculator.updateBalances(for: group, with: expense2)
        let member2Debt2 = calculator.debtBetween(payer: member1, borrower: member2, in: group)
        XCTAssertEqual(member2Debt2, 6)
        let member3Debt2 = calculator.debtBetween(payer: member1, borrower: member3, in: group)
        XCTAssertEqual(member3Debt2, 18)
        XCTAssertEqual(member1.totalBalance, 18)
        XCTAssertEqual(member2.totalBalance, 18)
        XCTAssertEqual(member3.totalBalance, -36)
    }

    func testCurrencyTable() {
        let exchangeRate1 = ExchangeRate(ownedCurrency: currencies[1], orderedCurrency: currencies[0], rate: 4)
        member1.exchangeRates.append(exchangeRate1)
        let expense = Expense(description: "desc2", amount: 10, tip: 6, date: Date(),
                              currency: currencies[1], payer: member2,
                              borrowers: [member1, member2],
                              contributions: [
                                Contribution(member: member1, value: 6),
                                Contribution(member: member2, value: 10)], items: [])

        guard let group = group else { return }
        calculator.normalizeExpense(expense, to: currencies[0]) { [unowned self] result in
            switch result {
            case .Error(error: _):
                XCTAssert(false)
            case .Success(result: let expense):
                self.calculator.updateBalances(for: group, with: expense)
                let member1Debt = self.calculator.debtBetween(payer: self.member2, borrower: self.member1, in: group)
                XCTAssertEqual(member1Debt, 30)
                XCTAssertEqual(self.member1.totalBalance, -6)
                XCTAssertEqual(self.member2.totalBalance, 18)
                XCTAssertEqual(self.member3.totalBalance, -36)
            }
        }
    }

    func testNormalizeExpenseWithGivenRate() {
        let expense = Expense(description: "desc2", amount: 10, tip: 6, date: Date(),
                              currency: currencies[1], payer: member2,
                              borrowers: [member1, member2],
                              contributions: [
                                Contribution(member: member1, value: 6),
                                Contribution(member: member2, value: 10)], items: [])
        guard let group = group else { return }
        let normalizedExpense = calculator.normaliceExpense(expense, to: currencies[0], with: 4)
        self.calculator.updateBalances(for: group, with: normalizedExpense)
        let member1Debt = self.calculator.debtBetween(payer: self.member2, borrower: self.member1, in: group)
        XCTAssertEqual(member1Debt, 24)
        XCTAssertEqual(self.member1.totalBalance, -24)
        XCTAssertEqual(self.member2.totalBalance, 24)
        XCTAssertEqual(self.member3.totalBalance, 0)
    }
}
