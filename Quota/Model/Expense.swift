//
//  Expense.swift
//  Quota
//
//  Created by Marcin Włoczko on 24/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

struct Expense: Encodable {
    let description: String
    let amount: Double
    let tip: Double?
    let date: Date
    let currency: Currency
    let payer: Member
    let borrowers: [Member]
    var contributions: [Contribution]
    var items: [BillItem]

    private enum CodingKeys: String, CodingKey {
        case description
        case amount
        case payer
        case contributions
    }

    func toCellData() -> SystemTableCellViewModel {
        return SystemTableCellViewModelImp(title: description,
                                           detailTitle: String(format: "%.2f", amount) + " " + currency.code)
    }
}
