//
//  RootCoordinator.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit

protocol RootCoordinator {
    func push(_ coordinator: Coordinator)
    func pop()
    func setRoot(_ coordinator: Coordinator)
}

protocol Coordinator: class {
    var rootCoordinator: RootCoordinator? { get set }
    var navigationController: UINavigationController? { get }
    var root: UIViewController? { get }
    func start()
}

final class RootCoordinatorImp: RootCoordinator {

    // MARK: - Constants

    private let window: UIWindow

    private var coordinators: [Coordinator] = []
    private var top: Coordinator? { return coordinators.first }
    private var root: Coordinator?

    // MARK: - Initializer

    init(window: UIWindow) {
        self.window = window
    }

    func push(_ coordinator: Coordinator) {
        guard top != nil else { return setRoot(coordinator) }
        coordinator.rootCoordinator = self
        coordinators.append(coordinator)
        coordinator.start()
    }

    func pop() {
        _ = coordinators.dropLast()
    }

    func setRoot(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
        root = coordinator
        coordinator.rootCoordinator = self
        coordinator.start()
        guard let navigationController = coordinator.navigationController else {
            fatalError("Root view controller is not set")
        }
        window.rootViewController = navigationController
    }
}
