//
//  InsertGroupBuilder.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol InsertGroupBuilder {
    func buildInsertGroupViewController() -> InsertGroupViewController
    func buildMemberViewController() -> MemberViewController
}

final class InsertGroupBuilderImp: InsertGroupBuilder {
    func buildInsertGroupViewController() -> InsertGroupViewController {
        let controller = InsertGroupViewController()
        let service = CurrencyServiceImp()
        let autocincrementer = AutoincrementerImp()
        let textFieldViewModel = CurrencyTextFieldViewModelImp(currencyService: service)
        controller.viewModel = InsertGroupViewModelImp(
            currencyTextFieldViewModel: textFieldViewModel,
            autoincrementer: autocincrementer)
        return controller
    }

    func buildMemberViewController() -> MemberViewController {
        let controller = MemberViewController()
        let autocincrementer = AutoincrementerImp()
        controller.viewModel = MemberViewModelImp(autoincrementer: autocincrementer)
        return controller
    }
}
