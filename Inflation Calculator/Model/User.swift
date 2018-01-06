//
//  User.swift
//  Inflation Calculator
//
//  Created by Cal Stephens on 1/6/17.
//  Copyright © 2017 Cal. All rights reserved.
//

import UIKit
import WatchConnectivity

class User : NSObject, WCSessionDelegate {
    
    private enum Key : String, UserDefaultsKey {
        case currencyIndex = "User.currencyIndex"
        case currencyUpgradePurchased = "User.currencyUpgradePurchased"
        case userHasRatedApp = "User.hasAlreadyRatedApp"
        case neverShowRateAlert = "User.doNotShowRateAlert"
        case numberOfAppLaunches = "User.numberOfLaunches"
        case amountTipped = "User.amountTipped"
        case tipCurrencyLocale = "User.tipCurrencyLocale"
    }
    
    static let current = User()
    
    private override init() { }
    
    
    //MARK: - Currency
    
    fileprivate var currencyIndex: Int {
        return UserDefaults.standard.integer(for: Key.currencyIndex)
    }
    
    var currency: Currency {
        let index = self.currencyIndex
        
        if index < 0 || index >= Currency.all.count {
            return .usDollar
        }
        
        return Currency.all[index]
    }
    
    func updateCurrency(to index: Int) {
        UserDefaults.standard.update(Key.currencyIndex, to: index)
        
        if #available(iOS 9.3, *) {
            self.pushSettingsToWatch()
        }
    }
    
    
    //MARK: - Upgrades
    
    private let purchasedFlag = "UserHasPurchased"
    
    var hasPurchasedCurrencyUpgrade: Bool {
        get {
            guard let string = UserDefaults.standard.get(Key.currencyUpgradePurchased) as? String else { return false }
            return string == self.purchasedFlag
        }
        
        set(newValue) {
            let valueToStore = (newValue) ? self.purchasedFlag : nil
            UserDefaults.standard.update(Key.currencyUpgradePurchased, to: valueToStore)
            UserDefaults.standard.synchronize()
        }
    }
    
    var tipCurrencyLocale: Locale {
        get {
            guard let identifier = UserDefaults.standard.get(Key.tipCurrencyLocale) as? String else { return .current }
            return Locale(identifier: identifier)
        }
        
        set {
            UserDefaults.standard.update(Key.tipCurrencyLocale, to: newValue.identifier)
            UserDefaults.standard.synchronize()
        }
    }
    
    var amountTipped: Double {
        get {
            return UserDefaults.standard.get(Key.amountTipped) as? Double ?? 0
        }
        
        set {
            UserDefaults.standard.update(Key.amountTipped, to: newValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    //MARK: - Rate Alert
    
    var numberOfAppLaunches: Int {
        get {
            return UserDefaults.standard.integer(for: Key.numberOfAppLaunches)
        }
        
        set(newValue) {
            UserDefaults.standard.update(Key.numberOfAppLaunches, to: newValue)
        }
    }
    
    var isEligableForRateAlert: Bool {
        return (numberOfAppLaunches == 4 || numberOfAppLaunches % 10 == 0)
            && numberOfAppLaunches != 0
    }
    
    
    //MARK: - Watch Connectivity
    
    fileprivate var onWatchSessionActivation: (() -> ())?
    
    fileprivate var dictionaryForWatch: [String : Any] {
        return ["currencyIndex" : self.currencyIndex]
    }
    
    @available(iOS 9.3, *)
    fileprivate func pushSettingsToWatch() {
        if WCSession.isSupported() {
            let session = WCSession.default
            
            let pushSettings: () -> () = {
                if session.isPaired && session.isWatchAppInstalled {
                    try? session.updateApplicationContext(self.dictionaryForWatch)
                }
            }
            
            if session.activationState != .activated {
                self.onWatchSessionActivation = pushSettings
                session.delegate = self
                session.activate()
            } else {
                pushSettings()
            }
        }
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //i guess this just won't work on 9.0-9.2?
        //I figure Apple Watch owners will be on 10.0+ anyway?
        
        if let onActivation = self.onWatchSessionActivation {
            onActivation()
            self.onWatchSessionActivation = nil
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) { }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
}


//MARK: - UserDefaults + Key

protocol UserDefaultsKey {
    var rawValue: String { get }
}

extension UserDefaults {
    
    func update(_ key: UserDefaultsKey, to value: Any?) {
        self.set(value, forKey: key.rawValue)
        self.synchronize()
    }
    
    func get(_ key: UserDefaultsKey) -> Any? {
        return self.object(forKey: key.rawValue)
    }
    
    func integer(for key: UserDefaultsKey) -> Int {
        return self.integer(forKey: key.rawValue)
    }
    
    func bool(for key: UserDefaultsKey) -> Bool {
        return self.bool(forKey: key.rawValue)
    }
}
