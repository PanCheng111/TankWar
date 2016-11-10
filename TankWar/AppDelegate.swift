//
//  AppDelegate.swift
//  TankWar
//
//  Created by 潘成 on 16/6/6.
//  Copyright © 2016年 潘成. All rights reserved.
//

import UIKit

var connectionManager : ConnectionManager! //= ConnectionManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow! //= UIWindow(frame: UIScreen.mainScreen().bounds)


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
            // Window
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let IntroVC = storyboard.instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
            window?.rootViewController = IntroVC
                //UINavigationController(rootViewController: MenuViewController())
            window?.makeKeyAndVisible()
        
            // Appearance
//            application.statusBarStyle = .LightContent
//            UINavigationBar.appearance().barTintColor = navBarColor
//            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: lightColor]
//            window?.tintColor = appTintColor
        
            // Simultaneously advertise and browse for other players
            //connectionManager.initSocket()
            return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //ConnectionManager.stop()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if connectionManager != nil {
            connectionManager.stop()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if connectionManager != nil {
            connectionManager.start()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if connectionManager != nil {
            connectionManager.stop()
        }
    }


}

