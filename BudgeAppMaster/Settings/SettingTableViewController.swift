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

class SettingTableViewController: UITableViewController {


    @IBOutlet weak var resetSpendingButtonOutlet: UIButton!
    @IBOutlet weak var resetRemindersButtonOutlet: UIButton!
    @IBOutlet weak var monthlyResetSwitch: UISwitch!
    @IBOutlet weak var signOutButtonOutlet: UIButton!
    
    @IBOutlet weak var pigCredit: UILabel!
    
    //For Credits
    let creditText = "Icons made by Freepic from www.flaticon.com"
    let pigArtist = "Freepic"
    let flatIcon = "www.flaticon.com"
    let rolloverText = "*Rollover*"
    
    
    var amt: Int = 0
    var referenceNote = 0
    var indexesToRemove = [Int]()
    var carryoverAmount = [Double]()
    
    
    
    
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
        
        
        
        
        if currentUserG == "" {
//            signOutButtonOutlet.isEnabled = false
//            signOutButtonOutlet.setTitle("", for: .normal)
            signOutButtonOutlet.setTitle("Log In", for: .normal)
        } else {
            signOutButtonOutlet.isEnabled = true
            signOutButtonOutlet.setTitle("Sign Out", for: .normal)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        db = Firestore.firestore()
        fireStoreListener()
       
        getUserDefaults()
        
        monthlyResetSwitch.onTintColor = Colors.themeGreenDark
        
        
        //Style Buttons
        resetSpendingButtonOutlet.backgroundColor = Colors.themeBlack
        resetSpendingButtonOutlet.setTitleColor(Colors.themeWhite, for: .normal)
        resetSpendingButtonOutlet.layer.cornerRadius = resetSpendingButtonOutlet.frame.height / 2
        
        resetRemindersButtonOutlet.backgroundColor = Colors.themeBlack
        resetRemindersButtonOutlet.setTitleColor(Colors.themeWhite, for: .normal)
        resetRemindersButtonOutlet.layer.cornerRadius = resetSpendingButtonOutlet.frame.height / 2
        
        
      
        
    }
    
    
    
    //MARK: SignOut
    @IBAction func signOutButton(_ sender: Any) {
        if currentUserG == "" {
            signUpMode = false
            performSegue(withIdentifier: "goToSignUp", sender: self)
        } else {
            signOutAlert()
        }
        
        
        
    }
    
    
 
    
    
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
    
    
    //MARK: Carryover Button
    @IBAction func resetAllBudgets(_ sender: Any) {
        resetAllBudgets()
    }
    
    func resetAllBudgets() {
        calculateCarryover()
        
//        var spentArray = [Double]()
//        for (_,value) in budgetHistoryAmountG {
//            spentArray.append(value.reduce(0, +))
//        }
//        let totalSpent = spentArray.reduce(0, +)
//        let totalBudgeted = budgetAmountG.reduce(0, +)
//        rolloverTotalG = totalBudgeted - totalSpent
        
    
        var needsCarryoverOption = false
        if carryoverAmount.count > 0 {
            for i in 0...carryoverAmount.count - 1 {
                if carryoverAmount[i] != 0.0 {
                    needsCarryoverOption = true
                }
            }
        }
        if needsCarryoverOption == true {
            let alert = UIAlertController(title: "Do you want to carryover your spending?" , message: "Any spending above or below your budgets will be applied to the next period.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes! Carryover my spending", style: UIAlertAction.Style.default, handler: { _ in
                self.applyCarryover()
                self.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                self.tabBarController?.selectedIndex = 0
            }))
                
            alert.addAction(UIAlertAction(title: "No. Just reset my budgets", style: UIAlertAction.Style.default, handler: { _ in
                self.resetBudgetsNoCarryover()
                self.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                self.tabBarController?.selectedIndex = 0
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                print("Cancel")
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Reset budgets?" , message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                print("Cancel")
            }))
            
            alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { _ in
                self.resetBudgetsNoCarryover()
                self.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                self.tabBarController?.selectedIndex = 0
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        //OLD
        /*
        if rolloverTotalG > 0.0 {
            //alert with rollover option
            
//            let alert = UIAlertController(title: "You have unspent money!" , message: "Do you want to rollover your unspent money into a \"Rollover\" budget?", preferredStyle: UIAlertController.Style.alert)
            
            let alert = UIAlertController(title: "You have unspent money!" , message: "Do you want to roll the excess over", preferredStyle: UIAlertController.Style.alert)
            
//            alert.addAction(UIAlertAction(title: "Yes! Rollover my money", style: UIAlertAction.Style.default, handler: { _ in
//                self.rolloverToRolloverBudget()
//                self.save()
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
//                self.tabBarController?.selectedIndex = 0
//
            alert.addAction(UIAlertAction(title: "Yes! Rollover my money", style: UIAlertAction.Style.default, handler: { _ in
                self.applyCarryover()
                self.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                self.tabBarController?.selectedIndex = 0
            }))
                
            alert.addAction(UIAlertAction(title: "No. Just reset my budgets", style: UIAlertAction.Style.default, handler: { _ in
                self.resetBudgetsNoRollover()
                self.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                self.tabBarController?.selectedIndex = 0
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
                self.save()
                self.tabBarController?.selectedIndex = 0
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
         */
        
        
    }
    
    //MARK: Carryover
    func calculateCarryover() {
        clearTempArrays()
        if budgetNameG.count > 0 {
            for i in 0...budgetNameG.count - 1 {
                carryoverAmount.append(0 - (budgetAmountG[i] - budgetHistoryAmountG[budgetNameG[i]]!.reduce(0, +)))
            }
            print("carryoverAmount: \(carryoverAmount)")
            //        applyCarryover()
        }
    }
    
    func applyCarryover() {
        
        resetBudgets()
        
        //FORMAT DATE AND TIME
        let formatterDate = DateFormatter()
        let formatterTime = DateFormatter()
        formatterDate.locale = Locale(identifier: "en_US_POSIX")
        formatterTime.locale = Locale(identifier: "en_US_POSIX")
        formatterDate.dateFormat = "MMMM dd"
        formatterTime.dateFormat = "h:mma"
        formatterTime.amSymbol = "am"
        formatterTime.pmSymbol = "pm"
        
        let dateString = formatterDate.string(from: Date())
        let timeString = formatterTime.string(from: Date())
        
        for i in 0...budgetNameG.count - 1 {
            budgetHistoryAmountG[budgetNameG[i]]?.insert(carryoverAmount[i], at: 0)
            budgetNoteG[budgetNameG[i]]?.insert("Carryover", at:0)
            budgetHistoryDateG[budgetNameG[i]]?.insert(dateString, at: 0)
            budgetHistoryTimeG[budgetNameG[i]]?.insert(timeString, at: 0)
        }

    }
    
    
    func resetBudgetsNoCarryover() {
        //RESET BUDGETS
        print("Reset Budgets, No Carryover")
//        var tempRolloverAmount = 0.0
//
//        if budgetNameG.contains(rolloverText) {
//            let index = budgetNameG.firstIndex(of: rolloverText)
//            tempRolloverAmount = budgetAmountG[index!]
//        }
        
        resetBudgets()
        rolloverTotalG = 0.0
        
//        if budgetNameG.contains(rolloverText) {
//            let index = budgetNameG.firstIndex(of: rolloverText)
//            budgetAmountG[index!] = tempRolloverAmount
//        }
        

    }
    

    
    
    
    //MARK: Reset Budgets
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
    

//    func rolloverToRolloverBudget() {
//        print("Reset Budgets and Rollover")
//
//        if budgetNameG.contains(rolloverText) {
//            resetBudgets()
//
//
//            //Find Index of Rollover Budget and set rollover budget
//            let indexOfRollover = budgetNameG.firstIndex(of: rolloverText)
//            budgetAmountG[indexOfRollover!] = rolloverTotalG
//
//        } else {
//            resetBudgets()
//            addRolloverBudget()
//        }
//    }
    
//    func deleteRolloverBudget() {
//        print("Delete Rollover Budget")
//        let indexOfRollover = budgetNameG.firstIndex(of: rolloverText)
//        budgetNameG.remove(at: indexOfRollover!)
//        budgetAmountG.remove(at: indexOfRollover!)
////        budgetRemainingG.remove(at: indexOfRollover!)
//        budgetHistoryAmountG.removeValue(forKey: rolloverText)
//        budgetHistoryDateG.removeValue(forKey: rolloverText)
//        budgetHistoryTimeG.removeValue(forKey: rolloverText)
//        budgetNoteG.removeValue(forKey: rolloverText)
//
//    }
    
    
//    func addRolloverBudget() {
//        budgetNameG.append(rolloverText)
//        let amount = Double(amt/100) + Double(amt%100)/100
//        budgetAmountG.append(rolloverTotalG)
//        budgetHistoryAmountG[rolloverText] = []
//        budgetNoteG[rolloverText] = []
//        budgetHistoryDateG[rolloverText] = []
//        budgetHistoryTimeG[rolloverText] = []
//        let totalSpent = budgetHistoryAmountG[rolloverText]?.reduce(0, +)
////        budgetRemainingG.append(amount - totalSpent!)
//    }
    
    @IBAction func resetReminders(_ sender: Any) {
        
        let alert = UIAlertController(title: "Reset reminders?" , message: "Repeating reminders will be reset and non-repeating reminders will be deleted.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            print("Cancel")
        }))
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
            self.resetReminderStatus()
            self.cancelNonRepeatingReminderNotifications()
            self.clearTempArrays()
            self.deleteNonRepeatingReminders()
            self.updateArrays()
            self.saveData()
            self.tabBarController?.selectedIndex = 1
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Delete account?" , message: "Deleting account will permanently delete your budgets and account information. If you are subscribed, you'll need to cancel that through iTunes.", preferredStyle: UIAlertController.Style.alert)
        
       
        
        alert.addAction(UIAlertAction(title: "Delete Account", style: UIAlertAction.Style.default, handler: { _ in
            print("DELETE ACCOUNT!!")
            self.deleteFirebaseDocument()
            self.deleteFirebaseAccount()
            self.signOut()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            print("Cancel")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func deleteFirebaseAccount() {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print("error: \(error)")
            } else {
                print("Account Deleted!")
            }
        }
    }
    
    func deleteFirebaseDocument() {
        if let userID = Auth.auth().currentUser?.uid {
            print("userID: \(userID)")
            db.collection("budgets").document(userID).delete() { err in
                if let err = err {
                    print("error: \(err)")
                } else {
                    print("Document Deleted!")
                    
                }
            }
        } else {
            print("delete account - no userID")
        }
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
        carryoverAmount = []
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
            setMonthlyResetLastMonth()
            setUserDefaultsResetSetting()
        } else {
            cancelResetNotification()
            monthlyResetSetting = false
            setUserDefaultsResetSetting()
        }
        
    }
    
    func setMonthlyResetLastMonth() {
        let date = Date()
        let calendar = Calendar.current
        let month = String(calendar.component(.month, from: date))
        let year = String(calendar.component(.year, from: date))
        var formattedMonth = String()
        
        // Add a "0" in front of the month integer if it's a single digit. This is needed so I can calculate if this date is less than the current date to know if the ResetAlert should be shown.
        if month.count == 1 {
            formattedMonth = "0\(month)"
        } else {
            formattedMonth = month
        }
        
        //combine year and month
        let combinedDates = "\(year)\(formattedMonth)"
        monthlyResetLastMonth = Int(combinedDates)!
        print(monthlyResetLastMonth)
        defaults.set(monthlyResetLastMonth, forKey: "MonthlyResetLastMonth")
        print("MonthlyResetLastMonth: \(monthlyResetLastMonth)")
    }
    
    
    //SCHEDULE NOTIFICATIONS
    func scheduleResetNotification() {
        
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "It's a new month, time to reset your budgets."
        content.subtitle = ""
        content.body = "Open Budge and go to Settings to reset your monthly budget."
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
    
   
    //MARK: SAVE
    func save() {
        if subscribedUser == true {
            saveToFireStore()
            print("Save to FireStore")
        } else {
            setUserDefaults()
            print("Save to UserDefaults")
        }
    }

    //MARK: Save to UserDefaults
    func setUserDefaults() {
        defaults.set(budgetNameG, forKey: "budgetNameUD")
        defaults.set(budgetAmountG, forKey: "budgetAmountUD")
        defaults.set(budgetHistoryAmountG, forKey: "budgetHistoryAmountUD")
        defaults.set(budgetHistoryDateG, forKey: "budgetHistoryDateUD")
        defaults.set(budgetHistoryTimeG, forKey: "budgetHistoryTimeUD")
        defaults.set(budgetNoteG, forKey: "budgetNoteUD")
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
                "subscribedUser": subscribedUser,
                "userID" : userID
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
        setUserDefaultsResetSetting()
    }
    
    func getUserDefaults() {
        monthlyResetSetting = defaults.bool(forKey: "MonthlyResetSetting")
//        subscribedUser = defaults.bool(forKey: "SubscribedUser")
        
        if defaults.object(forKey: "RegisteredDate") != nil {
            registeredDate = defaults.object(forKey: "RegisteredDate") as! Date
        }
    }
    
    func setUserDefaultsResetSetting() {
        defaults.set(monthlyResetSetting, forKey: "MonthlyResetSetting")
        
        
    }
   
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        subscribedUser = false
        currentUserG = ""
        clearDefaults()
        do {
            try firebaseAuth.signOut()
            deleteReminders()
            currentUserG = ""
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "signoutReload"), object: nil)
            reloadView = true
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showWelcomeScreen"), object: nil)
            needToShowWelcomeScreen = true
            self.tabBarController?.selectedIndex = 0
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func clearDefaults() {
        budgetNameG.removeAll()
        budgetAmountG.removeAll()
        budgetHistoryAmountG.removeAll()
        budgetHistoryDateG.removeAll()
        budgetHistoryTimeG.removeAll()
        budgetNoteG.removeAll()
        
        defaults.set(budgetNameG, forKey: "budgetNameUD")
        defaults.set(budgetAmountG, forKey: "budgetAmountUD")
        defaults.set(budgetHistoryAmountG, forKey: "budgetHistoryAmountUD")
        defaults.set(budgetHistoryDateG, forKey: "budgetHistoryDateUD")
        defaults.set(budgetHistoryTimeG, forKey: "budgetHistoryTimeUD")
        defaults.set(budgetNoteG, forKey: "budgetNoteUD")
    }
    
    
 
    //MARK:SYNC BUTTON
    @IBAction func linkToAnotherDevice(_ sender: Any) {
        
        //not subscribed, not signed in -> intro>subscribe>signup>instructions
        if subscribedUser == false && currentUserG == "" {
            signUpMode = true
            performSegue(withIdentifier: "goToSubscription", sender: self)
        }
        
        //subscribed, not signed in -> login/signup>instructions
        if subscribedUser == true && currentUserG == "" {
            signUpMode = true
            performSegue(withIdentifier: "goToSignUp", sender: self)
        }
        
        //not subscribed, signed in -> intro>subscribe>instructions
        if subscribedUser == false && currentUserG != "" {
            performSegue(withIdentifier: "goToSubscription", sender: self)
        }
        
        
        //subscribed, signed in -> instructions
        if subscribedUser == true && currentUserG != "" {
            print("show sync instructions")
            goToSyncInstructions()
        }
        
        emailG = Auth.auth().currentUser?.email! ?? ""
        
        //            let alert = UIAlertController(title: "Sync with Another Device", message: "To sync with another device, simply login with same email (\(String(describing: email))) and password as the original device.", preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //            self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func goToSyncInstructions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "syncInstructionsNav")
        self.present(viewController, animated: true)
    }
    
    
    func signOutAlert() {
        let alert = UIAlertController(title: "Sign out?", message: "Reminders are deleted when signing out, but your budgets and spending are saved and will here when you sign back in.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { action in
            self.signOut()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: FireStore Listener
    func fireStoreListener() {
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard document.data() != nil else {
                        print("Document data was empty.")
                        return
                    }
                    subscribedUser = document.get("subscribedUser") as! Bool
                    print("From Firestore, subscribedUser = \(subscribedUser)")
                    
            }
        }
        
        
    }
    
    
    
    //For Credits
    func setupView() {
        pigCredit.text = creditText
        
        let formattedText = String.format(strings: [pigArtist, flatIcon],
//                                          boldFont: UIFont.boldSystemFont(ofSize: 15),
                                          boldColor: UIColor.darkGray,
                                          inString: creditText,
//                                          font: UIFont.systemFont(ofSize: 15),
                                          color: UIColor.black)
        pigCredit.attributedText = formattedText
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
        pigCredit.addGestureRecognizer(tap)
        pigCredit.isUserInteractionEnabled = true
        
    }
    
    //For Credits
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = creditText as NSString
        let termRange = termString.range(of: pigArtist)
        let policyRange = termString.range(of: flatIcon)
        
        let tapLocation = gesture.location(in: pigCredit)
        let index = pigCredit.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        if checkRange(termRange, contain: index) == true {
            handleViewTermOfUse()
            return
        }
        
        if checkRange(policyRange, contain: index) {
            handleViewPrivacy()
            return
        }
    }
    
    //For Credits
    func handleViewTermOfUse() {
        guard let url = URL(string: "https://www.freepik.com/") else { return }
        UIApplication.shared.open(url)
    }
    
    //For Credits
    func handleViewPrivacy() {
        guard let url = URL(string: "https://www.flaticon.com") else { return }
        UIApplication.shared.open(url)
    }
    
    //For Credits
    func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    
    
    
}

//For Credits
extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

//For Credits
extension String {
    static func format(strings: [String],
                       boldFont: UIFont = UIFont.boldSystemFont(ofSize: 14),
                       boldColor: UIColor = UIColor.blue,
                       inString string: String,
                       font: UIFont = UIFont.systemFont(ofSize: 14),
                       color: UIColor = UIColor.black) -> NSAttributedString {
        let attributedString =
            NSMutableAttributedString(string: string,
                                      attributes: [
                                        NSAttributedString.Key.font: font,
                                        NSAttributedString.Key.foregroundColor: color])
        let boldFontAttribute = [NSAttributedString.Key.font: boldFont, NSAttributedString.Key.foregroundColor: boldColor]
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        return attributedString
    }
}

