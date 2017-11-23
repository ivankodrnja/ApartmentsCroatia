//
//  AppDelegate.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 28/03/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // when app first launches set default sync date
        print(NetworkClient.sharedInstance().defaults.object(forKey: "firstLaunch") as Any)
        if NetworkClient.sharedInstance().defaults.object(forKey: "firstLaunch") == nil {
            
            // default sync date, up to this date all date is synced and preloaded in the bundle
            let stringLastSyncDate = "2017-11-23"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let lastSyncDate = dateFormatter.date(from:stringLastSyncDate)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: lastSyncDate!)
            let finalLastSyncDate = calendar.date(from:components)
            
            NetworkClient.sharedInstance().defaults.set(finalLastSyncDate, forKey: "lastSyncDate")
            NetworkClient.sharedInstance().defaults.set(false, forKey: "firstLaunch")
        } else {
            NetworkClient.sharedInstance().defaults.set(false, forKey: "firstLaunch")
        }
        DispatchQueue.main.async {
            Flurry.startSession(flurryApiKey);
            Flurry.logAllPageViews(forTarget: UITabBarController.self)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

