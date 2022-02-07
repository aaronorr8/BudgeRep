//
//  GlobalConstants.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 5/1/20.
//  Copyright © 2020 Icecream. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase


//Budget Screen Colors
enum Colors {
    static let themeWhite = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let themeGray = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
    static let themeGreen = #colorLiteral(red: 0.5529411765, green: 0.6745098039, blue: 0.4117647059, alpha: 1)
    static let themeGreenDark = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
    static let themeYellow = #colorLiteral(red: 0.9529411765, green: 0.8549019608, blue: 0.5529411765, alpha: 1)
    static let themeRed = #colorLiteral(red: 0.8549019608, green: 0.6352941176, blue: 0.6352941176, alpha: 1)
    static let themeBlue = #colorLiteral(red: 0.5411764706, green: 0.6705882353, blue: 0.862745098, alpha: 1)
    static let themeBlack = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let themeClear = UIColor.clear

}



var reloadView = false



//Save Spend Alert
var showToast = false
var toastSuccess = true
var savedBudget = String()
var savedAmount = String()

//MINUTES BEFORE SHOWING IAP
let freeMinutes = 10080 //7 days

//Number of free budgets
let freeBudgets = 2


//User Attributes
var currentUserG = ""
var subscribedUser = Bool() //user is subscribed, no ads, unlimited budgets, and save to firebase to sync
var unlimitedUser = Bool()  //user is subscribed, no ads, unlimited budgets, but save to defaults - can not sync
var emailG = ""



//Database
var db:Firestore!
