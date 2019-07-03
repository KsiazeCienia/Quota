//
//  Autoincrementer.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation

protocol Autoincrementer: class {
    func getNext() -> Int
}

final class AutoincrementerImp: Autoincrementer {

    func getNext() -> Int {
        if let currentIndex = getCurrentIndex() {
            saveCurrentIndex(currentIndex + 1)
            return currentIndex
        } else {
            saveCurrentIndex(1)
            return 0
        }
    }

    func saveCurrentIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: "index")
    }

    func getCurrentIndex() -> Int? {
        return UserDefaults.standard.value(forKey: "index") as? Int
    }
}
