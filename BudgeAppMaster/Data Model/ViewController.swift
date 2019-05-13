//
//  ViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/8/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard


//NAVIGATION
var myIndexG = 0
var editModeG = false
var closeAllG = false


//SETTINGS
var monthlyResetSetting = false
var monthlyResetLastMonth = 0

//IAP
var registeredDate = Date()
var iapDate = Date().addingTimeInterval(12345678)
var subscribedUser = Bool()



//TEMP DATA
var presetAmountG = 0.0
var presetRefundG = false
var presetNote = ""

//USER DATA
var incomeG = 0.0
var billNameG = [String]()
var billAmountG = [Double]()
var billDateG = [String]()
var billPaidG = [Int]()
var billHistoryAmountG = [String: [Double]]()
var billHistoryDateG = [String: [String]]()

//WARNING: [SAVE THIS TO USER DEFAULTS]
var notificationUniqueID = 0



var budgetNameG = [String]() //array of budget names e.g., [grocery, clothing, etc]
var budgetAmountG = [Double]() //array of the budget amounts [grocery budget, clothing budget, etc]
var budgetRemainingG = [Double]() //array of the remaining amount in each budget
var budgetHistoryAmountG = [String: [Double]]()
var budgetHistoryDateG = [String: [String]]()
var budgetHistoryTimeG = [String: [String]]()
var budgetNoteG = [String: [String]]()
//var totalSpentG = Double() //a running total of money spent from all budgets
var rolloverG = Bool()
var rolloverTotalG = Double()


func convertDoubleToCurency(amount: Double) -> String {
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale.current
    
    return numberFormatter.string(from: NSNumber(value: amount))!
    
}

class ViewController: UIViewController {
    

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  


}



