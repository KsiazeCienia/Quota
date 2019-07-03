//
//  BillViewController.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

final class BillViewController: QuotaViewController {

    // MARK: - Views

    private let cropArea: CropArea = {
        let cropArea = CropArea()
        cropArea.translatesAutoresizingMaskIntoConstraints = false
        return cropArea
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonter.font(size: 14, weight: .semiBold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let cropImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.tealButtonStyle(fontSize: 16)
        button.isHidden = true
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()

    private lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Variables

    var viewModel: BillViewModel? {
        didSet {
            updateView()
            setupBinding()
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - VC's life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAppearance()
        setupNavigationBar()
    }

    // MARK: - Action Sheet

    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil,
                                            preferredStyle: .actionSheet)

        let galeryAction = UIAlertAction(title: viewModel?.galleryTitle, style: .default)
        { _ in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }
        let cameraAction = UIAlertAction(title: viewModel?.cameraTitle, style: .default)
        { _ in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)

        }
        let cancelAction = UIAlertAction(title: viewModel?.cancelTitle,
                                         style: .cancel, handler: { _ in})

        [galeryAction, cameraAction, cancelAction].forEach(actionSheet.addAction)
        present(actionSheet, animated: true, completion: nil)
    }

    // MARK: - Setup

    private func updateView() {
        guard let viewModel = viewModel else { return }
        addImageButton.setTitle(viewModel.addImageTitle, for: .normal)
        cropImageButton.setTitle(viewModel.cropImageTitle, for: .normal)
        infoLabel.text = viewModel.infoTitle
        let image = UIImage(named: viewModel.cancelAsset)!.withRenderingMode(.alwaysOriginal)
        cancelButton.setImage(image, for: .normal)
    }

    private func setupBinding() {
        guard let viewModel = viewModel else { return }

        cancelButton.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)

        addImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showActionSheet()
                self?.cropImageButton.isHidden = false
                self?.addImageButton.isHidden = true
            }).disposed(by: disposeBag)

        cropImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                SVProgressHUD.show()
                guard let self = self,
                    let bounds = self.cropArea.viewModel?.cropArea.value else { return }
                let image = self.imageView.cropImage(in: bounds)
                viewModel.image.accept(image)
            }).disposed(by: disposeBag)

    }

    private func setupNavigationBar() {
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: cancelButton),
                                        animated: true)
    }

    private func setupAppearance() {
        view.backgroundColor = .white
    }

    private func setupLayout() {
        [imageView, cropArea, stackView,
         infoLabel].forEach(view.addSubview)

        [addImageButton,
         cropImageButton].forEach(stackView.addArrangedSubview)

        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(60)
        }

        stackView.snp.makeConstraints {
            $0.bottom.leading.trailing
                .equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }

        cropArea.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(15)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-15)
            $0.bottom.equalTo(stackView.snp.top).offset(-15)
        }

        imageView.snp.makeConstraints {
            $0.edges.equalTo(cropArea)
        }
    }
}

extension BillViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        infoLabel.text = viewModel?.selectedImageTitle
        let cropAreaViewModel = CropAreaViewModelImp(frame: cropArea.frame)
        cropArea.viewModel = cropAreaViewModel
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        addImageButton.isHidden = false
        cropImageButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}
