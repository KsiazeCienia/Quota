//
//  CropArea.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CropArea: UIControl {

    // MARK: - Variables

    var viewModel: CropAreaViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }

    // MARK: - View's life cycle

    override func draw(_ rect: CGRect) {
        guard let area = viewModel?.cropArea.value else { return }
        let cropArea = UIBezierPath(rect: area)
        cropArea.lineWidth = 3
        UIColor.black.setStroke()
        cropArea.stroke()
    }

    // MARK: - Event hanlders

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        return viewModel?.shouldBeginTracking(location: location) ?? false
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        viewModel?.follow(location: location)
        return true
    }

    // MARK: - Setup

    private func updateView() {
        setNeedsDisplay()
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        viewModel.cropArea
            .subscribe(onNext: { [weak self] rect in
                self?.setNeedsDisplay()
            }).disposed(by: disposeBag)
    }

    private func setupAppearance() {
        backgroundColor = .clear
    }
}
