//
//  Group.swift
//  Quota
//
//  Created by Marcin Włoczko on 18/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

class Group: Encodable {
    let id: Int
    let name: String
    let currency: Currency
    let members: [Member]
    var expenses: [Expense]

    init(id: Int, name: String, currency: Currency,
         members: [Member], expenses: [Expense]) {
        self.name = name
        self.currency = currency
        self.members = members
        self.expenses = expenses
        self.id = id
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case currency
        case expenses
    }

    func toCellData() -> SystemTableCellViewModel {
        return SystemTableCellViewModelImp(title: name,
                                           accessoryType: .disclosureIndicator)
    }
}


