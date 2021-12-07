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
    static let budgetViewMainbackground1 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let budgetViewMainbackground2 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let budgetViewCellBackground = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
    static let budgetViewCellText = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let budgetViewTotalBudgetRemainingLabel = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let budgetViewSummaryOfTotalBudgetSpent = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let progressBarTrackCell = UIColor.clear
    static let progressBarTrackTotal = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
    static let progressBarProgressGreen = #colorLiteral(red: 0.5529411765, green: 0.8078431373, blue: 0.7647058824, alpha: 1)
    static let progressBarProgressYellow = #colorLiteral(red: 1, green: 0.9058823529, blue: 0.5215686275, alpha: 1)
    static let progressBarProgressRed = #colorLiteral(red: 0.9647058824, green: 0.5647058824, blue: 0.5568627451, alpha: 1)
    static let progressBarProgressBlue = #colorLiteral(red: 0.4117647059, green: 0.7294117647, blue: 0.8666666667, alpha: 1)
    static let themeAccentPrimary = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let themeAccentGreen = #colorLiteral(red: 0, green: 0.6134323478, blue: 0.5483384132, alpha: 1)
    static let themeAccentGray = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
    static let buttonPrimaryBackground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let buttonPrimaryText = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let navigationBarBackground = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let navigationBarText = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let deleteButton = #colorLiteral(red: 0.8039215686, green: 0.02352941176, blue: 0, alpha: 1)
    static let editButton = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let toggleGeneral = #colorLiteral(red: 0, green: 0.6134323478, blue: 0.5483384132, alpha: 1)
}






//COLORS
//let colorTrackH = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
//let colorRedH = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
//let colorGreenH = #colorLiteral(red: 0, green: 0.5241034031, blue: 0.3747756481, alpha: 1)
//
//let colorTrackC = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
//let colorRedC = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
//let colorGreenC = #colorLiteral(red: 0.3764705882, green: 0.8274509804, blue: 0.5803921569, alpha: 1)

var reloadView = false

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


//User Attributes
var currentUserG = ""
var subscribedUser = Bool() //user is subscribed, no ads, unlimited budgets, and save to firebase to sync
var unlimitedUser = Bool()  //user is subscribed, no ads, unlimited budgets, but save to defaults - can not sync



//Database
var db:Firestore!
