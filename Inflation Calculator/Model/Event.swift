//
//  Event.swift
//  Inflation Calculator
//
//  Created by Cal Stephens on 10/30/17
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Fabric
import Crashlytics

// MARK: Event

enum Event {
    case appLaunched
    case leftYearSelected(year: Int)
    case rightYearSelected(year: Int)
    
    case upgradeScreenViewed
    case upgradeScreenDimissed
    case upgradeCurrencyListViewed
    
    case currencyScreenViewed
    case currencySelected(currency: String)
    
    static func recordInternationalCurrenciesPurchased() {
        Answers.logPurchase(
            withPrice: 1.99,
            currency: "USD",
            success: true,
            itemName: "International Currencies",
            itemType: "Upgrade",
            itemId: "currencies",
            customAttributes: nil)
    }
}

// MARK: Event+Fabric

extension Event {
    
    func record() {
        print("Recorded \"\(eventName)\"")
        Answers.logCustomEvent(withName: eventName, customAttributes: customAttributes)
    }
    
    private var eventName: String {
        switch(self) {
        case .appLaunched: return "App Launched"
        case .leftYearSelected(_): return "Year Selected (left)"
        case .rightYearSelected(_): return "Year Selected (right)"
        case .upgradeScreenViewed: return "Upgrade Screen Viewed"
        case .currencyScreenViewed: return "Currency Screen Viewed"
        case .currencySelected(_): return "Currency Selected"
        case .upgradeScreenDimissed: return "Upgrade Screen Dismissed"
        case .upgradeCurrencyListViewed: return "Upgrade Currency List Viewed"
        }
    }
    
    private var customAttributes: [String: Any]? {
        switch(self) {
        case .leftYearSelected(year: let year):
            return ["year": year]
        case .rightYearSelected(year: let year):
            return ["year": year]
        case .currencySelected(currency: let currency):
            return ["currency": currency]
        default:
            return nil
        }
    }
    
}
