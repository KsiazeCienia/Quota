//
//  BillViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TesseractOCR

protocol BillViewModelDelegate: class {
    func billViewModel(didCreate items: [BillItem])
    func billViewModelRequestDismiss()
}

protocol BillViewModel: class {

    var delegate: BillViewModelDelegate? { get set }

    var addImageTitle: String { get }
    var cropImageTitle: String { get }
    var infoTitle: String { get }
    var selectedImageTitle: String { get }
    var cameraTitle: String { get }
    var galleryTitle: String { get }
    var cancelAsset: String { get }
    var cancelTitle: String { get }

    var image: BehaviorRelay<UIImage?> { get }
    var cancelAction: PublishRelay<Void> { get }
}

final class BillViewModelImp: BillViewModel {

    // MARK: - View's componenets

    let addImageTitle: String = "add_image".localized
    let cropImageTitle: String = "crop_image".localized
    let infoTitle: String = "bill_info".localized
    let selectedImageTitle: String = "selected_bill_info".localized
    let galleryTitle: String = "bill_gallery".localized
    let cameraTitle: String = "bill_camera".localized
    let cancelTitle: String = "cancel".localized
    let cancelAsset: String = "dismiss"

    // MARK: - Observers

    let image = BehaviorRelay<UIImage?>(value: nil)
    let cancelAction = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK; - Delegate

    weak var delegate: BillViewModelDelegate?

    private let billRecognizer: BillRecognizer

    init(billRecognizer: BillRecognizer) {
        self.billRecognizer = billRecognizer
        setupBinding()
    }

    private func setupBinding() {
        image.subscribe(onNext: { [weak self] (image) in
            guard let self = self,
                let image = image else { return }
            self.billRecognizer.recognize(from: image) { [weak self] items in
                guard let items = items else { return }
                self?.delegate?.billViewModel(didCreate: items)
            }
        }).disposed(by: disposeBag)

        cancelAction.subscribe(onNext: { [weak self] in
            self?.delegate?.billViewModelRequestDismiss()
        }).disposed(by: disposeBag)
    }
}
