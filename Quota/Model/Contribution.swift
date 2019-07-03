//
//  Contribution.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/12/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation

class Contribution: Encodable {
    let member: Member
    var value: Double

    init(member: Member, value: Double) {
        self.member = member
        self.value = value
    }
}
