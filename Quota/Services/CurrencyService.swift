//
//  CurrencyService.swift
//  Quota
//
//  Created by Marcin Włoczko on 18/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CurrencyService {
    func fetchCurrencies() -> Observable<[Currency]>
}

final class CurrencyServiceImp: CurrencyService {

    func fetchCurrencies() -> Observable<[Currency]> {
        let path = Bundle.main.path(forResource: "Currencies",
                                    ofType: "json")!

        return Observable.create({ observer in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path),
                                    options: .mappedIfSafe)
                let currencies = try decoder.decode([Currency].self,
                                                    from: data)
                observer.onNext(currencies)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        })
    }
}
