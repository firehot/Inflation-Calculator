//
//  ViewController.swift
//  Inflation Calculator
//
//  Created by Cal on 10/4/14.
//  Copyright (c) 2015 Cal. All rights reserved.
//

import UIKit

let ICOpenCountKey = "ICOpenCountKey"
let ICNeverAskForRateKey = "ICNeverAskForRateKey"

class ViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet var leftYearLabel: UILabel!
    @IBOutlet var leftYearButton: UIButton!
    @IBOutlet var rightYearLabel: UILabel!
    @IBOutlet var rightYearButton: UIButton!
    
    @IBOutlet var datePicker: UIPickerView!
    @IBOutlet var leftAmountLabel: UILabel!
    @IBOutlet var leftAmountButton: UIButton!
    @IBOutlet var rightAmountLabel: UILabel!
    @IBOutlet var rightAmountButton: UIButton!
    @IBOutlet var yearPicker: UIPickerView!
    @IBOutlet var clearButton: UIButton!
    
    var activeLabel : UILabel? = nil
    var CPI : Array<Double> = []
    
    var leftAmount : Double = 0
    var rightAmount : Double = 0
    var leftTemp : Double = 0
    var rightTemp : Double = 0
    
    var leftDecimal : Bool = false
    var rightDecimal : Bool = false
    var leftHasOneDecimal : Bool = false
    var rightHasOneDecimal : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aspectRatio = Double(self.view.bounds.size.height / self.view.bounds.size.width)
        
        if(aspectRatio < 1.7 && self.view.bounds.size.height < 700){
            leftYearLabel.hidden = true
            rightYearLabel.hidden = true
            leftYearButton.hidden = true
            rightYearButton.hidden = true
            
            let constraint = NSLayoutConstraint(item: yearPicker, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: clearButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 30)
            self.view.addConstraint(constraint)
            
        } else {
            let constraint = NSLayoutConstraint(item: yearPicker, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: rightYearLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 25)
            self.view.addConstraint(constraint)
        }
        
        
        if(self.view.bounds.height < 667){ //4S, 5, 5S
            let constraint = NSLayoutConstraint(item: yearPicker, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: yearPicker, attribute: NSLayoutAttribute.Height, multiplier: 1.90531, constant: 1) //1.97531
            self.view.addConstraint(constraint)
        }
        if(self.view.bounds.height > 730){ //6Plus
            let constraint = NSLayoutConstraint(item: yearPicker, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: yearPicker, attribute: NSLayoutAttribute.Height, multiplier: 1.59, constant: 1)
            self.view.addConstraint(constraint)
        }
        
        //load CPI data
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("CPIdata", ofType: "txt")
        let content = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        let strings = content.componentsSeparatedByString("\n")
        for s in strings {
            CPI.append(NSString(string: s).doubleValue)
        }
        
        activeLabel = leftAmountLabel
        datePicker.delegate = self
        datePicker.selectRow(36, inComponent: 0, animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        if animated { return }
        //update open count and show alert if appropriate
        let data = NSUserDefaults.standardUserDefaults()
        if !data.boolForKey(ICNeverAskForRateKey) {
            let openCount = data.integerForKey(ICOpenCountKey) + 1
            data.setInteger(openCount, forKey: ICOpenCountKey)
            
            if openCount % 3 == 0 { //show alert
                let alert = UIAlertController(title: "Rate Inflation Calculator?", message: "If you love Inflation Calculator, would you mind giving it a rating on the App Store? It'll only take a sec.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Sure", style: .Default, handler: { _ in
                    data.setBool(true, forKey: ICNeverAskForRateKey)
                    UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://appsto.re/us/Wyip3.i")!)
                }))
                
                alert.addAction(UIAlertAction(title: "Later", style: .Cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "No, don't ask again", style: .Destructive, handler: { _ in
                    data.setBool(true, forKey: ICNeverAskForRateKey)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func numberButtonPressed(sender: UIButton) {
        var currentValue : Double
        var hasDecimal : Bool
        var hasOneDecimal : Bool
        
        if(activeLabel == leftAmountLabel){
            currentValue = leftAmount
            hasDecimal = leftDecimal
            hasOneDecimal = leftHasOneDecimal
            rightDecimal = true
            rightHasOneDecimal = true
            leftTemp = 0
            rightTemp = 0
        } else {
            currentValue = rightAmount
            hasDecimal = rightDecimal
            hasOneDecimal = rightHasOneDecimal
            leftDecimal = true
            leftHasOneDecimal = true
            leftTemp = 0
            rightTemp = 0
        }
        
        if(currentValue >= 999999999999 && !(hasDecimal)){
            return;
        }
        
        if(hasDecimal){
            if(hasOneDecimal){
                if(String(NSString(format: "%.02f", currentValue)).hasSuffix("0")){
                   currentValue += Double(Int(sender.titleLabel!.text!)!) / 100
                }
            }else{
                currentValue += Double(Int(sender.titleLabel!.text!)!) / 10
                if(activeLabel == leftAmountLabel){
                    leftHasOneDecimal = true
                } else {
                    rightHasOneDecimal = true
                }
            }
        }
        
        else{
            currentValue *= 10
            currentValue += Double(Int(sender.titleLabel!.text!)!)
        }
        
        if(activeLabel == leftAmountLabel){
           leftAmount = currentValue
        } else {
            rightAmount = currentValue
        }
        
        self.updateAmounts()
    }
    
    @IBAction func pointButtonPressed(sender: UIButton) {
        if(activeLabel == leftAmountLabel && !(leftDecimal)){
            leftDecimal = true
            leftHasOneDecimal = false
        } else if (activeLabel == rightAmountLabel && !(rightDecimal)){
            rightDecimal = true
            rightHasOneDecimal = false
        }
        updateAmounts()
    }
    
    func updateAmounts() {
        var activeAmount : Double
        var inactiveLabel : UILabel
        var activeYear : Int
        var inactiveYear : Int
        var activeHasDecimal : Bool
        if(activeLabel == leftAmountLabel){
            activeAmount = leftAmount
            activeHasDecimal = leftDecimal
            activeYear = Int(leftYearLabel.text!)!
            inactiveLabel = rightAmountLabel
            inactiveYear = Int(rightYearLabel.text!)!
        } else {
            activeAmount = rightAmount
            activeHasDecimal = rightDecimal
            activeYear = Int(rightYearLabel.text!)!
            inactiveLabel = leftAmountLabel
            inactiveYear = Int(leftYearLabel.text!)!
        }
        
        let activeCPI = CPI[CPI.count - (2017 - activeYear)]
        let inactiveCPI = CPI[CPI.count - (2017 - inactiveYear)]
        
        let inactiveAmount : Double = activeAmount * (inactiveCPI / activeCPI)
        
        if(activeLabel == leftAmountLabel){
            rightAmount = inactiveAmount
        }else{
            leftAmount = inactiveAmount
        }
        
        inactiveLabel.text = formatAmount(inactiveAmount, hasDecimal: true)
        activeLabel!.text = formatAmount(activeAmount, hasDecimal: activeHasDecimal)
    }
    
    func formatAmount(amount:Double, hasDecimal:Bool) -> String {
        let floatRounded = String(NSString(format: "%.02f", amount))
        
        let range = Range<String.Index>(start: floatRounded.startIndex, end: floatRounded.endIndex.predecessor().predecessor().predecessor())
        var withoutDecimal = floatRounded.substringWithRange(range)
        
        
        var pieces : Array<String> = []
        while(withoutDecimal.characters.count > 3){
            let index = withoutDecimal.endIndex.predecessor().predecessor().predecessor()
            pieces.append(withoutDecimal.substringFromIndex(index))
            withoutDecimal = withoutDecimal.substringToIndex(index)
        }
        pieces.append(withoutDecimal)
        
        pieces = Array(pieces.reverse())
        var moneyFormatted = pieces[0]
        if(pieces.count > 1){
            for i in 1...(pieces.count - 1){
                moneyFormatted += ",\(pieces[i])"
            }
        }
        
        if(hasDecimal){
            moneyFormatted += floatRounded.substringFromIndex(range.endIndex)
        }
        
        return "$\(moneyFormatted)"
    }
    
    @IBAction func amountButtonPressed(sender: UIButton) {
        if(sender.tag == 1){ //left button
            activeLabel = leftAmountLabel
            rightAmountButton.backgroundColor = UIColor(red: 40/255, green: 154/255, blue: 100/255, alpha: 1)
            leftAmountButton.backgroundColor = UIColor(red: 14/255, green: 105/255, blue: 56/255, alpha: 1)
            rightYearButton.backgroundColor = UIColor(red: 40/255, green: 154/255, blue: 100/255, alpha: 1)
            leftYearButton.backgroundColor = UIColor(red: 17/255, green: 131/255, blue: 76/255, alpha: 1)
            leftHasOneDecimal = false
            leftDecimal = false
            leftTemp = (leftTemp != 0 ? leftTemp : leftAmount)
            leftAmount = 0
        }
        else{ //right button
            activeLabel = rightAmountLabel
            leftAmountButton.backgroundColor = UIColor(red: 40/255, green: 154/255, blue: 100/255, alpha: 1)
            rightAmountButton.backgroundColor = UIColor(red: 14/255, green: 105/255, blue: 56/255, alpha: 1)
            leftYearButton.backgroundColor = UIColor(red: 40/255, green: 154/255, blue: 100/255, alpha: 1)
            rightYearButton.backgroundColor = UIColor(red: 17/255, green: 131/255, blue: 76/255, alpha: 1)
            rightHasOneDecimal = false
            rightDecimal = false
            rightTemp = (rightTemp != 0 ? rightTemp : rightAmount)
            rightAmount = 0
        }
    }
    
    @IBAction func clearButtonPressed(sender: UIButton) {
        leftAmount = 0
        rightAmount = 0
        leftDecimal = false
        rightDecimal = false
        self.updateAmounts()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return (2016 - 1799)
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        //let attributedString = NSAttributedString(string: "\(2016 - row)", attributes: [NSForegroundColorAttributeName : UIColor(red: 57/255, green: 150/255, blue: 86/255, alpha: 1)])
        let attributedString = NSAttributedString(string: "\(2016 - row)", attributes: [NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1)])
        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            leftYearLabel.text = String(2016 - row)
            updateWithTemps()
            
        }else{
            rightYearLabel.text = String(2016 - row)
            updateWithTemps()
        }
    }
    
    func updateWithTemps(){
        if(leftTemp != 0){
            leftAmount = leftTemp
            leftDecimal = true
        }
        if(rightTemp != 0){
            rightAmount = rightTemp
            rightDecimal = true
        }
            updateAmounts()
        if(leftTemp != 0){
            leftDecimal = false
            leftAmount = 0
        }
        if(rightTemp != 0){
            rightDecimal = false
            rightAmount = 0
        }
        
    }
    
    @IBAction func returned (segue: UIStoryboardSegue){
        return;
    }
    
}
