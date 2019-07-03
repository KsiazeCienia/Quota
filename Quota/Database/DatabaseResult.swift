//
//  DatabaseResult.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

enum DatabaseResult<T> {
    case error(error: Error)
    case success(result: [T])
}
