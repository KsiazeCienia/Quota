//
//  AppDelegate.swift
//  Quota
//
//  Created by Marcin Włoczko on 03/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var rootCoordinator: RootCoordinator?

    // MARK:- Application's life cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupNavigation()
        return true
    }

    //MARK:- Main

    private func setupNavigation() {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let `window` = window else { fatalError("Window couldn't be initialized") }
        window.makeKeyAndVisible()
        let builder = GroupsBuilderImp()
        let groupsCoordinator = GroupsCoordiantor(builder: builder)
        rootCoordinator = RootCoordinatorImp(window: window)
        rootCoordinator?.push(groupsCoordinator)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseManager.shared.saveContext()
    }
}

