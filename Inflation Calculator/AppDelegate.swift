//
//  AppDelegate.swift
//  Inflation Calculator
//
//  Created by Cal on 10/4/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import UIKit
import StoreKit
import Fabric
import Crashlytics
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self, Answers.self])
        Event.appLaunched.record()
        
        self.appBecameVisible()
        
        //prepare to listen for IAPs
        SKPaymentQueue.default().add(StoreManager.main)

        return true
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.appBecameVisible()
    }
    
    func appBecameVisible() {
        User.current.numberOfAppLaunches += 1
        
        if User.current.isEligableForRateAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            }
        }
    }

}

