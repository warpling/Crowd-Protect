//
//  AppDelegate.swift
//  crowd protect
//
//  Created by Ryan McLeod on 6/2/20.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = MainEditorViewController()
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

