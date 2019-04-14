//
//  AddReminderViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 11/16/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import UserNotifications

var noteReference = 0 //Used for notification identifier
var noteDay = 0 //used to schedule notification on specific day

class AddReminderViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var reminderNameInput: UITextField!
    @IBOutlet weak var reminderAmountInput: UITextField!
    @IBOutlet weak var dueDateInput: UITextField!
    @IBOutlet weak var selectBudgetField: UITextField!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var repeatSwitchOutlet: UISwitch!
    @IBOutlet weak var notificationSwitchOutlet: UISwitch!
    @IBOutlet weak var reminderLabel1: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    

    var amt: Int = 0
    var budgets = budgetNameG
    var currentTextField = UITextField()
    var dueDateOptions = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th", "21st", "22nd", "23rd", "24th", "25th", "26th", "27th", "28th"]
    var repeatSetting = true
    var notificationSetting = true


    override func viewDidLayoutSubviews() {
        //Add underline to text fields
        reminderNameInput.setUnderLine()
        reminderAmountInput.setUnderLine()
        selectBudgetField.setUnderLine()
        
        scrollView.bounces = false
        
    }
    
    
    override func viewDidLoad() {
        
        
        
        //Get User Default Values
        notificationUniqueID = defaults.integer(forKey: "NotificationUniqueID")
     
        super.viewDidLoad()
        
        print("myIndexG: \(myIndexG)")
    

        //SET NAV TITLE
        navItem.title = "Add Bill Reminder"
        
        reminderAmountInput.delegate = self
        reminderAmountInput.placeholder = updateAmount()
        
        //SET FIRST RESPONDER
        self.reminderNameInput.becomeFirstResponder()
        
        //SET REPEAT AND NOTIFICATION SETTINGS
        if editModeG == true {
            repeatSetting = reminderArray[myIndexG].reminderRepeat
            notificationSetting = reminderArray[myIndexG].notificationSetting
        } else {
            repeatSetting = true
            notificationSetting = false
        }
        
        
        //PICKER VIEW LINKED BUDGET
        let pickerViewLinkedBudget = UIPickerView()
        pickerViewLinkedBudget.delegate = self as UIPickerViewDelegate
        selectBudgetField.inputView = pickerViewLinkedBudget
        
        //CHANGE HEADER IF THERE ARE NO BUDGETS CREATED YET
        budgets.insert("Link to a budget:", at: 0)
        if budgets.count == 1 {
            budgets[0] = "No budgets have been added"
        }
        
        
        //PICKER DUE DATE
        let pickerViewDueDate = UIPickerView()
        pickerViewDueDate.delegate = self as UIPickerViewDelegate
        dueDateInput.inputView = pickerViewDueDate
       
        
        //LOAD PRESETS
        if editModeG != true {
            //SET NAV TITLE (ADD NEW MODE)
            navItem.title = "Add Reminder"
        } else {
            //SET NAV TITLE (EDIT MODE)
            navItem.title = "Edit Reminder"
            
            //SET DEFAULT VALUES
            selectBudgetField.text = reminderArray[myIndexG].linkedBudget
            reminderNameInput.text = reminderArray[myIndexG].name
            reminderAmountInput.text = convertDoubleToCurency(amount: reminderArray[myIndexG].amount)
            amt = Int(reminderArray[myIndexG].amount) * 100
            
            //ADD "ST", "ND", "RD", "ST" TO DATE
            if reminderArray[myIndexG].date == 0 {
                dueDateInput.text = "1st"
            } else if reminderArray[myIndexG].date == 1 || reminderArray[myIndexG].date == 21 {
                dueDateInput.text = String("\(reminderArray[myIndexG].date)st")
            } else if reminderArray[myIndexG].date == 2 || reminderArray[myIndexG].date == 22 {
                dueDateInput.text = String("\(reminderArray[myIndexG].date)nd")
            } else if reminderArray[myIndexG].date == 3 || reminderArray[myIndexG].date == 23 {
                dueDateInput.text = String("\(reminderArray[myIndexG].date)rd")
            } else {
                dueDateInput.text = String("\(reminderArray[myIndexG].date)th")
            }
            
            //SET REPEAT SWITCH
            repeatSwitchOutlet.isOn = reminderArray[myIndexG].reminderRepeat
            
            //SET NOTIFICATION SWITCH
            notificationSwitchOutlet.isOn = reminderArray[myIndexG].notificationSetting
            
            //HIDE OR UNHIDE REMINDER INPUTS
            if reminderArray[myIndexG].notificationSetting == false {
                reminderLabel1.isHidden = true
                dueDateInput.isHidden = true
            } else {
                reminderLabel1.isHidden = false
                dueDateInput.isHidden = false
            }
            
        }
    }
    
    
    
    //MARK: NAVIGATION BAR APPEARANCE
    func setNavigationBarColor() {
        navBar.barTintColor = bgColorGradient1
        navBar.isTranslucent = false
        cancelButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = bgColorGradient1
        view.addSubview(barView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        editModeG = false
        print("editModeG = \(editModeG)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK: REPEAT SWITCH
    @IBAction func repeatSwitchButton(_ sender: Any) {
        self.view.endEditing(true)
        if (repeatSwitchOutlet.isOn) == true {
            print("Repeat On")
            repeatSetting = true
        } else {
            print("Repeat Off")
            repeatSetting = false
        }
        print(repeatSetting)
    }
    
    
    //MARK: NOTIFICATION SWITCH
    @IBAction func notificationSwitchButton(_ sender: Any) {
        self.view.endEditing(true)
        if (notificationSwitchOutlet.isOn) == true {
            print("Notification On")
            
            //REQUEST NOTIFICATION PERMISSION
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                print("not allowed")
            })
            
            notificationSetting = true
            reminderLabel1.isHidden = false
            dueDateInput.isHidden = false
        } else {
            print("Notification Off")
            notificationSetting = false
            reminderLabel1.isHidden = true
            dueDateInput.isHidden = true
        }
        print(notificationSetting)
    }
    
    //MARK: SAVE BUTTON
    @IBAction func saveButton(_ sender: Any) {
        
        let newReminder = ReminderItem()
        
        //ADD NEW MODE
        if editModeG != true {
            
            //ADD NAME
            if reminderNameInput != nil {
                newReminder.name = reminderNameInput.text!
            }
            
            //ADD AMOUNT
            if reminderAmountInput != nil {
                let amount = Double(amt/100) + Double(amt%100)/100
                newReminder.amount = amount
            }
            
            //ADD LINKED BUDGET
            if selectBudgetField != nil {
                newReminder.linkedBudget = selectBudgetField.text!
            } else {
                newReminder.linkedBudget = selectBudgetField.text!
            }
            
            //ADD DATE
            if dueDateInput != nil {
                if notificationSwitchOutlet.isOn == true {
                    
                    //REMOVE LAST 2 CHARACTERS FROM STRING
                    let tempDay = dueDateInput.text!
                    let modifiedDay = tempDay.dropLast(2)
                    newReminder.date = Int(modifiedDay)!
                    noteDay = Int(modifiedDay)!
                    noteReference = notificationUniqueID
                    scheduleNotifications()
                } else {
                    newReminder.date = 0
                }
            }
            
            //ADD REPEAT SETTING
            newReminder.reminderRepeat = repeatSetting
            
            //ADD NOTIFICATION ID
            newReminder.notificationID = notificationUniqueID
            
            //ADD NOTIFICATION SETTING
            newReminder.notificationSetting = notificationSetting
            
            //ADD REMINDER STATUS
            newReminder.done = false
            
            
            reminderArray.append(newReminder)
            
            //Increment notificationUniqueID
            notificationUniqueID = notificationUniqueID + 1
            
            //Save to User Defaults
            defaults.set(notificationUniqueID, forKey: "NotificationUniqueID")
            
            print("notificationUniqueID: \(notificationUniqueID)")
            
            
        } else {
            //MARK: EDIT MODE
            //UPDATE NAME
            if reminderNameInput != nil {
                reminderArray[myIndexG].name = reminderNameInput.text!
                //                self.dismiss(animated: true, completion: nil)
            }
            
            //UPDATE AMOUNT
            if reminderAmountInput != nil {
                let amount = Double(amt/100) + Double(amt%100)/100
                reminderArray[myIndexG].amount = amount
            }
            
            //UPDATE LINKED BUDGET
            if selectBudgetField != nil {
                reminderArray[myIndexG].linkedBudget = selectBudgetField.text!
            }
            
            //UPDATE DATE
            if dueDateInput != nil {
                if notificationSwitchOutlet.isOn == true {
                    
                    //REMOVE LAST 2 CHARACTERS FROM STRING
                    let tempDay = dueDateInput.text!
                    let modifiedDay = tempDay.dropLast(2)
                    reminderArray[myIndexG].date = (Int(modifiedDay)!)
                    
                    noteDay = reminderArray[myIndexG].date
                    print("noteDay: \(noteDay)")
                    noteReference = reminderArray[myIndexG].notificationID
                    scheduleNotifications()
                } else {
                    reminderArray[myIndexG].date = 0
                    noteReference = reminderArray[myIndexG].notificationID
                    cancelNotifications()
                }
            }
            
            //UPDATE REPEAT SETTING
            reminderArray[myIndexG].reminderRepeat = repeatSetting
            
            // UPDATE NOTIFICATION SETTING
            reminderArray[myIndexG].notificationSetting = notificationSetting
            
            
        }
        
        saveData()
        self.dismiss(animated: true, completion: nil)

    }
    
   
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //FORMAT AMOUNT
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                let alert = UIAlertController(title: "You don't make that much", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                reminderAmountInput.text = ""
                
                amt = 0
                
            } else {
                reminderAmountInput.text = updateAmount()
            }
            
            reminderAmountInput.text = updateAmount()
        }
        
        if string == "" {
            amt = amt/10
            reminderAmountInput.text = amt == 0 ? "" : updateAmount()
        }
        
        return false
    }
    //FORMAT AMOUNT
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
    
    //PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if currentTextField == selectBudgetField {
            return 1
//        } else if currentTextField == selectRecurrenceField {
//                return 1
        } else if currentTextField == dueDateInput {
            return 1
        } else {
            return 0
        }
        
    }
    //PICKER VIEW
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == selectBudgetField {
            return budgets.count
        } else if currentTextField == dueDateInput {
            return dueDateOptions.count
        } else {
            return 0
        }
    }
    //PICKER VIEW
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == selectBudgetField {
            return budgets[row]
        } else if currentTextField == dueDateInput {
            return dueDateOptions[row]
        } else {
            return ""
        }
    }
    //PICKER VIEW
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == selectBudgetField {
            if row == 0 {
                selectBudgetField.text = ""
            } else {
                selectBudgetField.text = budgets[row]
            }
        } else if currentTextField == dueDateInput {
            dueDateInput.text = dueDateOptions[row]
        }
    }

    
    //GET CURRENT TEXT FIELD
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    //SCHEDULE NOTIFICATIONS
    func scheduleNotifications() {
        
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Bill Reminder: \(reminderNameInput.text!)"
        content.subtitle = ""
        content.body = ""
        content.badge = 1
        
        //trigger on a specific date and time
        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 30
//        dateComponents.weekday = 2
//        dateComponents.second = noteDay
        dateComponents.day = noteDay
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let reference = String(noteReference)
        let noteID = "notificationID\(reference)"
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: noteID, content: content, trigger: trigger)
        
        print("notification request: \(request)")
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    //CANCEL NOTIFICATIONS
    func cancelNotifications() {
        let reference = noteReference
        let noteID = "notificationID\(reference)"
        print(noteID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noteID])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //MARK: NDM
    func saveData() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(reminderArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding reminder array, \(error)")
        }
    }
    
     
}



