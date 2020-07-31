//
//  AppDelegate.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 6/22/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SocketIOManager.getInstance.name = SocketIOManager.getInstance.randomString(length: 4)
        
        addObservers()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        SocketIOManager.getInstance.name = SocketIOManager.getInstance.randomString(length: 4)
//
//        addObservers()
//        return true
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    func addObservers(){
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToForeground() {
        print("Connecting")
        SocketIOManager.getInstance.connect()
    }
    
    @objc func appMovedToBackground() {
        if(!SocketIOManager.getInstance.inRace){
            SocketIOManager.getInstance.isConnected = false
            SocketIOManager.getInstance.showHomeVC?()
            SocketIOManager.getInstance.disconnect()
        }
    }
    

    
    
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
////        SocketIOManager.sharedInstance.establishConnection()
//        print("active")
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
////        SocketIOManager.sharedInstance.closeConnection()
//        print("no longer active")
//    }


}

