//
//  AppDelegate.swift
//  testBadger
//
//  Created by Milos Otasevic on 29/04/2020.
//  Copyright © 2020 Milos Otasevic. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var connection: Connection = { fatalError("Device is called before being initialized")}()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.connection = Connection()
        self.connection.setCentral()
        return true
    }
}
