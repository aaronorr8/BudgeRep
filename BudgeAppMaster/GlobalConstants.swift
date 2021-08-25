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
let colorBackground1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
let colorBackground2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
let colorCellBackground = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
let colorCellText = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
let colorTotalBudgetRemaining = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)





//COLORS
let colorTrackH = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
let colorRedH = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
let colorGreenH = #colorLiteral(red: 0, green: 0.5241034031, blue: 0.3747756481, alpha: 1)

let colorTrackC = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
let colorRedC = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
let colorGreenC = #colorLiteral(red: 0.3764705882, green: 0.8274509804, blue: 0.5803921569, alpha: 1)

let bgColorSolid = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
let bgColorGradient1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
let bgColorGradient2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

let cellBackground = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

//new color scheme
let colorLightText = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)


//Save Spend Alert
var showToast = false
var toastSuccess = true
var savedBudget = String()
var savedAmount = String()

//MINUTES BEFORE SHOWING IAP
let freeMinutes = 10080 //7 days

//Number of free budgets
let freeBudgets = 3

//Cross Controls
var reloadBudgetViewCC = false


//User Attributes
var currentUserG = ""
var subscribedUser = Bool() //user is subscribed, no ads, unlimited budgets, and save to firebase to sync
var unlimitedUser = Bool()  //user is subscribed, no ads, unlimited budgets, but save to defaults - can not sync



//Database
var db:Firestore!
