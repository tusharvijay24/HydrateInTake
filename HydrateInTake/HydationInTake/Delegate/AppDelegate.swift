//
//  AppDelegate.swift
//  HydationInTake
//
//  Created by Tushar on 19/05/24.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the application's managed object context before the application terminates.
    }
}
