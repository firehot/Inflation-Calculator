//
//  AboutViewController.swift
//  Inflation Calculator
//
//  Created by Cal Stephens on 1/5/18.
//  Copyright © 2018 Cal. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var sourcesStackView: UIStackView!
    @IBOutlet weak var tipJarDescription: UILabel!
    @IBOutlet weak var smallTipButton: UIButton!
    @IBOutlet weak var largeTipButton: UIButton!
    
    var loadedProducts = [StoreIdentifier: SKProduct]()
    
    // MARK: Setup
    
    override func viewDidLoad() {
        Event.aboutScreenViewed.record()
        updateVersionLabel()
        updateSourcesList()
        updateTipPrices()
        updateTipDescription()
    }
    
    private func updateVersionLabel() {
        versionLabel.text = "Version \(Bundle.applicationVersionNumber) (\(Bundle.applicationBuildNumber))"
    }
    
    private func updateSourcesList() {
        sourcesStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        for (index, currency) in Currency.all.enumerated() {
            let source = Source.of(currency)
            let sourceStackView = UIStackView()
            sourceStackView.axis = .vertical
            
            let currencyLabel = UILabel()
            currencyLabel.font = .systemFont(ofSize: 17)
            currencyLabel.text = "\(currency.flag) \(currency.name)"
            sourceStackView.addArrangedSubview(currencyLabel)
            
            let sourceButton = UIButton(type: .system)
            sourceButton.setTitle(source.name, for: .normal)
            sourceButton.setTitleColor(#colorLiteral(red: 0.1568627954, green: 0.6078432202, blue: 0.3960783482, alpha: 1), for: .normal)
            sourceButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            sourceButton.contentHorizontalAlignment = .left
            sourceButton.titleLabel?.lineBreakMode = .byTruncatingTail
            sourceButton.tag = index
            sourceButton.addTarget(self, action: #selector(sourceButtonPressed(_:)), for: .touchUpInside)
            sourceStackView.addArrangedSubview(sourceButton)
            
            sourcesStackView.addArrangedSubview(sourceStackView)
        }
    }
    
    private func updateTipPrices() {
        StoreManager.main.requestProduct(withIdentifier: .smallTip, completion: { product in
            self.updateTipButton(self.smallTipButton, with: product)
            self.loadedProducts[.smallTip] = product
        })
        
        StoreManager.main.requestProduct(withIdentifier: .largeTip, completion: { product in
            self.updateTipButton(self.largeTipButton, with: product)
            self.loadedProducts[.largeTip] = product
        })
    }
    
    private func updateTipButton(_ button: UIButton, with product: SKProduct?) {
        guard let product = product else { return }
        
        let formatter = NumberFormatter()
        formatter.locale = product.priceLocale
        formatter.numberStyle = .currency
        let price = formatter.string(from: product.price) ?? "$0.99"
        
        print("Received price \(price) for \(product.localizedTitle)")
        
        UIView.setAnimationsEnabled(false)
        button.setTitle("Tip \(price)", for: .normal)
        UIView.setAnimationsEnabled(true)
    }
    
    private func updateTipDescription() {
        let attributes = tipJarDescription.attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:]
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = User.current.tipCurrencyLocale
        let amountTipped = formatter.string(from: NSNumber(value: User.current.amountTipped)) ?? "$0"
        
        let noTipText = NSAttributedString(
            string: "You can support the development of Inflation Calculator by leaving a tip.",
            attributes: attributes)
        
        let hasTippedText = NSAttributedString(
            string: "You have tipped \(amountTipped). Thank you for supporting the development of Inflation Calculator!",
            attributes: attributes)
        
        tipJarDescription.attributedText = (User.current.amountTipped > 0) ? hasTippedText : noTipText
    }
    
    // MARK: User Interaction
    
    @IBAction func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func websiteButtonTapped() {
        let website = URL(string: "http://calstephens.tech")!
        let safariViewController = SFSafariViewController(url: website)
        present(safariViewController, animated: true, completion: nil)
        Event.aboutWebsiteVisited.record()
    }
    
    @IBAction func smallTipButtonPressed() {
        purchaseTipProduct(loadedProducts[.smallTip])
        flashButton(smallTipButton)
    }
    
    @IBAction func largeTipButtonPressed() {
        purchaseTipProduct(loadedProducts[.largeTip])
        flashButton(largeTipButton)
    }
    
    private func flashButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            button.titleLabel?.alpha = 0.2
        })
        
        UIView.animate(withDuration: 0.6, animations: {
            button.titleLabel?.alpha = 1.0
        })
    }
    
    private func purchaseTipProduct(_ product: SKProduct?, waitIfNotLoaded: Bool = true) {
        guard StoreManager.main.userCanMakePayments else {
            showAlert(
                title: "Cannot purchase upgrade",
                message: "Your Apple ID is not able to make payments. This may be due to parental controls or missing payment information.")
            return
        }
        
        guard let tipProduct = product else {
            if waitIfNotLoaded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.purchaseTipProduct(product, waitIfNotLoaded: false)
                })
            } else {
                showAlert(
                    title: "Cannot Connect to App Store",
                    message: "We could not download purchase information from the App Store. You may not be connected to the internet.")
            }
            
            return
        }
        
        StoreManager.main.purchase(tipProduct, completion: { success in
            if success {
                self.showAlert(
                    title: "Tip Received",
                    message: "Thank you for supporting the development of Inflation Calculator!")
                
                User.current.amountTipped += tipProduct.price.doubleValue
                User.current.tipCurrencyLocale = tipProduct.priceLocale
                self.updateTipDescription()
                
                if tipProduct.productIdentifier == StoreIdentifier.smallTip.rawValue {
                    Event.recordSmallTipPurchased()
                } else if tipProduct.productIdentifier == StoreIdentifier.largeTip.rawValue {
                    Event.recordLargeTipPurchased()
                }
            }
        })
    }
    
    private func showAlert(title: String, message: String, buttonText: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func sourceButtonPressed(_ button: UIButton) {
        let currency = Currency.all[button.tag]
        let source = Source.of(currency)
        
        let safariViewController = SFSafariViewController(url: source.url)
        present(safariViewController, animated: true, completion: nil)
        
        Event.currencySourceWebsiteVisited(currency: currency.name).record()
    }
    
}

// MARK: Bundle + Version

extension Bundle {
    
    static var applicationVersionNumber: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Version Number Not Available"
    }
    
    static var applicationBuildNumber: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Build Number Not Available"
    }
    
}
