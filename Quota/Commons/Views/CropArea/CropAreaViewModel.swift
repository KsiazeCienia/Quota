//
//  CropAreaViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CropAreaViewModel: class {

    var cropArea: BehaviorRelay<CGRect> { get }

    func shouldBeginTracking(location: CGPoint) -> Bool
    func follow(location: CGPoint)
}

final class CropAreaViewModelImp: CropAreaViewModel {

    // MARK: - Observers

    let cropArea = BehaviorRelay<CGRect>(value: .zero)
    private let disposeBag = DisposeBag()

    // MARK: - Variables

    private var rectangle: Rectangle

    // MARK: - Initializer

    init(frame: CGRect) {
        self.rectangle = Rectangle(frame: frame)
        setupBinding()
    }

    // MARK: - Main

    func shouldBeginTracking(location: CGPoint) -> Bool {
        return rectangle.contains(point: location)
    }

    func follow(location: CGPoint) {
        rectangle.moveClosest(to: location)
    }

    // MARK: - Setup

    private func setupBinding() {
        rectangle.frame
            .bind(to: cropArea)
            .disposed(by: disposeBag)
    }
}

