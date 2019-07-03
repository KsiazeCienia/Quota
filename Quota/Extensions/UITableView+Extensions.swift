//
//  UITableView+Extensions.swift
//  Quota
//
//  Created by Marcin Włoczko on 06/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

extension UITableView {

    func register(_ cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.identifier)
    }

    func dequeueReusableCell<Cell: UITableViewCell>(_ cellType: Cell.Type,
                                                    for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as! Cell
    }
}
