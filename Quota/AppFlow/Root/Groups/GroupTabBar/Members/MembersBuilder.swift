//
//  MembersBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol MembersBuilder: class {
    func buildMembersViewController(with group: Group) -> MembersViewController
    func buildMemberDetailViewController(with member: Member, in group: Group) -> MemberDetailViewController
    func buildCurrencyTableViewController(with member: Member) -> CurrencyTableViewController
    func buildExchangeRateViewController(with exchangeRate: ExchangeRate?) -> ExchangeRateViewController
}

final class MembersBuilderImp: MembersBuilder {
    func buildMembersViewController(with group: Group) -> MembersViewController {
        let controller = MembersViewController()
        controller.viewModel = MembersViewModelImp(group: group)
        return controller
    }

    func buildMemberDetailViewController(with member: Member, in group: Group) -> MemberDetailViewController {
        let expensesCalculator = ExpensesCalculatorImp()
        let controller = MemberDetailViewController()
        controller.viewModel = MemberDetailViewModelImp(member: member, group: group, expensesCalculator: expensesCalculator)
        return controller
    }

    func buildCurrencyTableViewController(with member: Member) -> CurrencyTableViewController {
        let controller = CurrencyTableViewController()
        controller.viewModel = CurrencyTabelViewModelImp(member: member)
        return controller
    }

    func buildExchangeRateViewController(with exchangeRate: ExchangeRate?) -> ExchangeRateViewController {
        let controller = ExchangeRateViewController()
        controller.viewModel = ExchangeRateViewModelImp(exchangeRate: exchangeRate)
        return controller
    }
}
