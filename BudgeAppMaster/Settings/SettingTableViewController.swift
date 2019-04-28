//
//  SettingTableViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 4/5/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

var goToMain = false
var hideCloseButton = true

class SettingTableViewController: UITableViewController {


    @IBOutlet weak var monthlyResetSwitch: UISwitch!
    
    
    
    
    var amt: Int = 0
    var referenceNote = 0
    var indexesToRemove = [Int]()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if goToMain == true {
            tabBarController?.selectedIndex = 0
            goToMain = false
        }
        
        
        monthlyResetSwitch.isOn = monthlyResetSetting
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("clear badge")
        
        //Load Notification Items
        loadItems()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        getUserDefaults()
        
    }
    
    
    
    //MARK: SignOut
    @IBAction func signOutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            deleteReminders()
            subscribedUser = false
            setUserDefaults()
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        
        subscribedUser = false
        setUserDefaults()
        print("reset")
       
    }
    
//
//
//
//
//
//
//    @IBAction func testItButton(_ sender: Any) {
//
//        if let userID = Auth.auth().currentUser?.uid {
//            db.collection("budgets").document(userID)
//                .addSnapshotListener { documentSnapshot, error in
//                    guard let document = documentSnapshot else {
//                        print("Error fetching document: \(error!)")
//                        return
//                    }
//                    guard let data = document.data() else {
//                        print("Document data was empty.")
//                        return
//                    }
//                    budgetNameG = document.get("budgetName") as! [String]
//                    budgetAmountG = document.get("budgetAmount") as! [Double]
//                    budgetHistoryAmountG = document.get("budgetHistoryAmount") as! [String : [Double]]
//                    budgetNoteG = document.get("budgetNote") as! [String : [String]]
//                    budgetHistoryDateG = document.get("budgetHistoryDate") as! [String : [String]]
//                    budgetHistoryTimeG = document.get("budgetHistoryTime") as! [String : [String]]
//                    budgetRemainingG = document.get("budgetRemaining") as! [Double]
//
//                    print("Current data: \(data)")
//
//            }
//
//
//        }
//
//
//    }
//
    
    
    //MARK: FireStore Listen for Data
    func listenDocument() {
        
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            db.collection("budgets").document(userID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    print("Current data: \(data)")
            }
        }
    }
    
    @IBAction func subscribeButton(_ sender: Any) {
        hideCloseButton = false
        
    }
    
    
    
    
    
//    @IBAction func notifyMeButton(_ sender: Any) {
//        let center = UNUserNotificationCenter.current()
//        center.getPendingNotificationRequests { (notifications) in
//            print("################## Count: \(notifications.count)")
//            for item in notifications {
//                print(item.content.title)
//                print(item.identifier)
//                print(item.trigger)
//                print("- - - - - - - - - -")
//            }
//        }
//    }
    
    
    
    @IBAction func resetAllBudgets(_ sender: Any) {
        
        let remainingAvailable = budgetRemainingG.reduce(0, +)
        
        if remainingAvailable > 0.0 {
            //alert with rollover option
            
            let alert = UIAlertController(title: "You have unspent money!" , message: "Do you want to rollover your unspent money into a \"Rollover\" budget?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes! Rollover my money", style: UIAlertAction.Style.default, handler: { _ in
                self.rolloverToRolloverBudget()
                self.resetReminderStatus()
                self.cancelNonRepeatingReminderNotifications()
                self.clearTempArrays()
                self.deleteNonRepeatingReminders()
                self.updateArrays()
                self.saveToFireStore()
                self.saveData()
            }))
            alert.addAction(UIAlertAction(title: "No. Just reset my budgets", style: UIAlertAction.Style.default, handler: { _ in
                self.resetBudgetsNoRollover()
                self.resetReminderStatus()
                self.cancelNonRepeatingReminderNotifications()
                self.clearTempArrays()
                self.deleteNonRepeatingReminders()
                self.updateArrays()
                self.saveToFireStore()
                self.saveData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                print("Cancel")
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //alert with confirm/cancel
            
            let alert = UIAlertController(title: "Reset budgets?" , message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                print("Cancel")
            }))
            
            alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { _ in
                self.resetBudgetsNoRollover()
                self.resetReminderStatus()
                self.cancelNonRepeatingReminderNotifications()
                self.clearTempArrays()
                self.deleteNonRepeatingReminders()
                self.updateArrays()
                self.saveToFireStore()
                self.saveData()
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func resetBudgetsNoRollover() {
        //RESET BUDGETS
        print("Reset Budgets, No Rollover")
        resetBudgets()
        budgetRemainingG = budgetAmountG
        totalSpentG = 0.0
        rolloverTotalG = 0.0
        
        if budgetNameG.contains("Rollover") {
            deleteRolloverBudget()
        }
    }
    
    func rolloverToRolloverBudget() {
        print("Reset Budgets and Rollover")
        rolloverTotalG = budgetRemainingG.reduce(0, +)
        
        if budgetNameG.contains("Rollover") {
            resetBudgets()
            totalSpentG = 0.0
            
            //Find Index of Rollover Budget and set rollover budget
            let indexOfRollover = budgetNameG.index(of: "Rollover")
            budgetAmountG[indexOfRollover!] = rolloverTotalG
            budgetRemainingG = budgetAmountG
            
        } else {
            resetBudgets()
            addRolloverBudget()
            budgetRemainingG = budgetAmountG
            totalSpentG = 0.0
        }
    }
    
    func deleteRolloverBudget() {
        print("Delete Rollover Budget")
        let indexOfRollover = budgetNameG.index(of: "Rollover")
        budgetNameG.remove(at: indexOfRollover!)
        budgetAmountG.remove(at: indexOfRollover!)
        budgetRemainingG.remove(at: indexOfRollover!)
        budgetHistoryAmountG.removeValue(forKey: "Rollover")
        budgetHistoryDateG.removeValue(forKey: "Rollover")
        budgetHistoryTimeG.removeValue(forKey: "Rollover")
        budgetNoteG.removeValue(forKey: "Rollover")
        
    }
    
    
    func addRolloverBudget() {
        budgetNameG.append("Rollover")
        let amount = Double(amt/100) + Double(amt%100)/100
        budgetAmountG.append(rolloverTotalG)
        budgetHistoryAmountG["Rollover"] = []
        budgetNoteG["Rollover"] = []
        budgetHistoryDateG["Rollover"] = []
        budgetHistoryTimeG["Rollover"] = []
        let totalSpent = budgetHistoryAmountG["Rollover"]?.reduce(0, +)
        budgetRemainingG.append(amount - totalSpent!)
    }
    
    
    func resetBudgets() {
        budgetHistoryAmountG.forEach({ (key, value) -> Void in
            budgetHistoryAmountG[key] = []
        })
        
        budgetNoteG.forEach({ (key, value) -> Void in
            budgetNoteG[key] = []
        })
        
        budgetHistoryDateG.forEach({ (key, value) -> Void in
            budgetHistoryDateG[key] = []
        })
        
        budgetHistoryTimeG.forEach({ (key, value) -> Void in
            budgetHistoryTimeG[key] = []
        })
    }
    
    func resetReminderStatus() {
        print("Reset Reminder Status")
        for i in 0..<(reminderArray.count){
            reminderArray[i].done = false
        }
    }
    
    
    func deleteNonRepeatingReminders() {
        print("Delete Non-Repeating Reminders")
        for i in 0..<(reminderArray.count) {
            if reminderArray[i].reminderRepeat == false {
                indexesToRemove.append(i)
            }
        }
    }
    
    func clearTempArrays() {
        indexesToRemove = []
    }
    
    
    func updateArrays() {
        
        let tempArray = reminderArray.enumerated().filter { !indexesToRemove.contains($0.offset)}.map { $0.element}
        reminderArray = tempArray
    }
    
    
    
    func cancelNonRepeatingReminderNotifications() {
        print("Cancel Notifications for Non-Repeating Reminders")
        for i in 0..<(reminderArray.count) {
            if reminderArray[i].reminderRepeat == false {
                noteReference = reminderArray[i].notificationID
                cancelNotifications()
            }
        }
    }
    
    
    //CANCEL NOTIFICATIONS
    func cancelNotifications() {
        let reference = noteReference
        let noteID = "notificationID\(reference)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noteID])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
    @IBAction func monthlyResetSwitch (_ sender: Any) {
        if monthlyResetSwitch.isOn == true {
            scheduleResetNotification()
            monthlyResetSetting = true
            setUserDefaults()
        } else {
            cancelResetNotification()
            monthlyResetSetting = false
            setUserDefaults()
        }
        
    }
    
    
    //SCHEDULE NOTIFICATIONS
    func scheduleResetNotification() {
        
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Time to reset your budgets."
        content.subtitle = ""
        content.body = "Open the app to reset your monthly budgets for the new month!"
        content.badge = 1
        
        //trigger on a specific date and time
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 10
        //        dateComponents.weekday = 2
        //        dateComponents.second = 0
        dateComponents.day = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let noteID = "ResetReminder"
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: noteID, content: content, trigger: trigger)
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //CANCEL NOTIFICATIONS
    func cancelResetNotification() {
        let noteID = "ResetReminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noteID])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func printPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
                print(item.content.title)
                print(item.identifier)
                print(item.trigger)
                print("- - - - - - - - - -")
            }
        }
    }
    
    func cancelAllReminderNotififications() {
        for i in 0..<(reminderArray.count) {
            noteReference = reminderArray[i].notificationID
            cancelNotifications()
        }
    }
    
    //MARK: Save to FireStore
    func saveToFireStore() {
        
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID).setData([
                "budgetName": budgetNameG,
                "budgetAmount": budgetAmountG,
                "budgetHistoryAmount": budgetHistoryAmountG,
                "budgetNote": budgetNoteG,
                "budgetHistoryDate": budgetHistoryDateG,
                "budgetHistoryTime": budgetHistoryTimeG,
                "budgetRemaining": budgetRemainingG,
                "totalSpent": totalSpentG,
                "subscribedUser": subscribedUser
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    
                }
            }
        }
    }
    
    //MARK: SAVE DATA TO CODEABLE
    func saveData() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(reminderArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding reminder array, \(error)")
        }
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                reminderArray = try decoder.decode([ReminderItem].self, from: data)
            } catch {
                print("Error decoding reminder array, \(error)")
            }
        }
    }
    
    func deleteReminders() {
        //Cancel reminder notifications
        cancelAllReminderNotififications()
        
        //Cancel monthly reset notification
        cancelResetNotification()
        
        //Delete all reminders
        reminderArray.removeAll()
        
        //Save
        saveData()
        
        //Turn of monthly reset switch
        monthlyResetSetting = false
        setUserDefaults()
    }
    
    func getUserDefaults() {
        monthlyResetSetting = defaults.bool(forKey: "MonthlyResetSetting")
        subscribedUser = defaults.bool(forKey: "SubscribedUser")
        
        if defaults.object(forKey: "RegisteredDate") != nil {
            registeredDate = defaults.object(forKey: "RegisteredDate") as! Date
        }
    }
    
    func setUserDefaults() {
        defaults.set(monthlyResetSetting, forKey: "MonthlyResetSetting")
        defaults.set(subscribedUser, forKey: "SubscribedUser")
    }
    
    
    
    
}



