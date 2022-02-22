//
//  RemindersViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 11/16/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import UserNotifications

var reminderArray = [ReminderItem]()
let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Reminder.plist")

class RemindersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var swipeToEditLabel: UILabel!
    @IBOutlet weak var addReminderButtonOutlet: UIBarButtonItem!
    
    var reminderIndex = 0



    override func viewDidAppear(_ animated: Bool) {
        remindersTableView.reloadData()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("clear badge")
        
        updateGuidanceLabel()
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        
        
        
    
    }
    
    func updateGuidanceLabel() {
        if reminderArray.isEmpty == true {
            swipeToEditLabel.text = "Add your first reminder"
        } else {
            swipeToEditLabel.text = "Swipe to edit"
        }
    }
    
    
    
    @IBAction func printDefaultsButton(_ sender: Any) {
        print("user defaults")
        if defaults.value(forKey: "budgetNameUD") != nil {budgetNameG = defaults.value(forKey: "budgetNameUD") as! [String]}
        if defaults.value(forKey: "budgetAmountUD") != nil {budgetAmountG = defaults.value(forKey: "budgetAmountUD") as! [Double]}
        if defaults.value(forKey: "budgetHistoryAmountUD") != nil {budgetHistoryAmountG = defaults.value(forKey: "budgetHistoryAmountUD") as! [String : [Double]]}
        if defaults.value(forKey: "budgetHistoryDateUD") != nil {budgetHistoryDateG = defaults.value(forKey: "budgetHistoryDateUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetHistoryTimeUD") != nil {budgetHistoryTimeG = defaults.value(forKey: "budgetHistoryTimeUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetNoteUD") != nil {budgetNoteG = defaults.value(forKey: "budgetNoteUD") as! [String: [String]]}
        if defaults.value(forKey: "SubscribedUser") != nil {subscribedUser = defaults.value(forKey: "SubscribedUser") as! Bool}
        print("budgetNameG: \(budgetNameG)")
        print("budgetAmountG: \(budgetAmountG)")
        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
        print("budgetHistoryDateG: \(budgetHistoryDateG)")
        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
        print("budgetNoteG: \(budgetNoteG)")
        print("SubscribedUser: \(subscribedUser)")
        
    }
    

    @objc func reloadTable() {
        remindersTableView.reloadData()
    }
    
    
    func setNavigationBarColor() {
        navBar.barTintColor = Colors.themeWhite
        navBar.isTranslucent = false
        navBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = Colors.themeWhite
        view.addSubview(barView)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return reminderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RemindersTableViewCell
      
        let reminderItem = ReminderItem()
        
        //DISPLAY NAME
        if reminderArray[indexPath.row].reminderRepeat == true {
            cell.reminderNameLabel.text = reminderArray[indexPath.row].name
        } else {
            cell.reminderNameLabel.addTextWithImage(text: "\(reminderArray[indexPath.row].name)", image: #imageLiteral(resourceName: "RepeatOff"), imageBehindText: true, keepPreviousText: false)
        }
        
        
        //SET CHECKMARK
        if reminderArray[indexPath.row].done == false {
            cell.checkmarkImage.image = #imageLiteral(resourceName: "CheckmarkOpen2")
            cell.checkmarkImage.image = cell.checkmarkImage.image?.withRenderingMode(.alwaysTemplate)
            cell.checkmarkImage.tintColor = Colors.themeGreenDark
        } else {
            cell.checkmarkImage.image = #imageLiteral(resourceName: "CheckmarkSolid")
            cell.checkmarkImage.image = cell.checkmarkImage.image?.withRenderingMode(.alwaysTemplate)
            cell.checkmarkImage.tintColor = Colors.themeGreenDark
        }
        
        //DISPLAY AMOUNT
        cell.amountLabel.text = String(convertDoubleToCurency(amount: reminderArray[indexPath.row].amount))

        //DISPLAY LINKED BUDGET
        if reminderArray[indexPath.row].linkedBudget == "" {
            cell.linkedBudget.text = ""
        } else {
            cell.linkedBudget.addTextWithImage(text: "\(reminderArray[indexPath.row].linkedBudget)", image: #imageLiteral(resourceName: "HashtagSymbol"), imageBehindText: false, keepPreviousText: false)
            cell.linkedBudget.addTextWithImage(text: "\(reminderArray[indexPath.row].linkedBudget)", image: #imageLiteral(resourceName: "HashtagSymbol"), imageBehindText: false, keepPreviousText: false)
        }
        
        //DISPLAY REMINDER DATE
        if reminderArray[indexPath.row].notificationSetting == true {

            //ADD "ST", "ND", "RD", "ST" TO DATE
            var formattedDay = String()
            if reminderArray[indexPath.row].date == 1 || reminderArray[indexPath.row].date == 21 {
                formattedDay = "st"
            } else if reminderArray[indexPath.row].date == 2 || reminderArray[indexPath.row].date == 22 {
                formattedDay = "nd"
            } else if reminderArray[indexPath.row].date == 3 || reminderArray[indexPath.row].date == 23 {
                formattedDay = "rd"
            } else {
                formattedDay = "th"
            }

            cell.dueDateLabel.text = "Reminder day: \(reminderArray[indexPath.row].date)\(formattedDay)"
 
        } else {
            cell.dueDateLabel.addTextWithImage(text: "", image: #imageLiteral(resourceName: "NotificationOff"), imageBehindText: false, keepPreviousText: false)
        }
        
        
        return cell
    }
    
    //MARK: SET CHECKMARK STATUS
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndexG = indexPath.row
        noteReference = reminderArray[myIndexG].notificationID
        
        //MARK REMINDER AS DONE
        if reminderArray[indexPath.row].done == false {
            reminderArray[indexPath.row].done = true
            
            //DEDUCT FROM LINKED BUDGET
            if reminderArray[indexPath.row].linkedBudget != "" && budgetNameG.contains(reminderArray[indexPath.row].linkedBudget){
                //OPEN DIALOG
                let alert = UIAlertController(title: "Done!", message: "Do you want to take this from \"\(reminderArray[indexPath.row].linkedBudget)\"?", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Yes, record in budget", style: UIAlertAction.Style.default, handler: { _ in
                   //MARK: NDM
                    myIndexG = budgetNameG.firstIndex(of: reminderArray[indexPath.row].linkedBudget)!
                    presetAmountG = reminderArray[indexPath.row].amount
                    self.switchViewToAddSpend()
                }))
                
                alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.default, handler: { _ in
                    print("Cancel")
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            cancelNotifications()
            saveData()
            
        } else {
            //MARK REMINDER AS NOT DONE
            reminderArray[indexPath.row].done = false
            
            //REFUND LINKED BUDGET
            if reminderArray[indexPath.row].linkedBudget != "" && budgetNameG.contains(reminderArray[indexPath.row].linkedBudget){
                //OPEN DIALOG
                let alert = UIAlertController(title: "Do you want to apply this back to your \"\(reminderArray[indexPath.row].linkedBudget)\" budget?", message: "", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.default, handler: { _ in
                    print("Cancel")
                }))
                
                alert.addAction(UIAlertAction(title: "Yes, adjust budget", style: UIAlertAction.Style.default, handler: { _ in
                    myIndexG = budgetNameG.firstIndex(of: reminderArray[indexPath.row].linkedBudget)!
                    presetAmountG = reminderArray[indexPath.row].amount
                    presetRefundG = true
                    self.switchViewToAddSpend()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            scheduleNotifications()
        }
        saveData()
        remindersTableView.reloadData()
        updateGuidanceLabel()
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //EDIT REMINDER
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.reminderIndex = indexPath.row
            myIndexG = indexPath.row
            editModeG = true
            self.switchViewAddReminder()
            
        }
        
        //DELETE REMINDER
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped for index \(indexPath.row)")
            self.reminderIndex = indexPath.row
            self.deleteReminder()
            self.saveData()
            tableView.reloadData()
            self.updateGuidanceLabel()
        }
    
        edit.backgroundColor = Colors.themeBlack
        delete.backgroundColor = Colors.themeRed
        
        return [edit, delete]
        
    }
    
    func deleteReminder() {
        print(reminderIndex)
        
        noteReference = reminderArray[reminderIndex].notificationID
        cancelNotifications()
        
        reminderArray.remove(at: reminderIndex)

    }
    
    @objc func switchViewToAddSpend() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddSpendNav")
        self.present(viewController, animated: true)
    }
    
    @objc func switchViewAddReminder() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddReminderNav")
        self.present(viewController, animated: true)
    }
    
    //SCHEDULE NOTIFICATIONS
    func scheduleNotifications() {
        
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Remember to pay \(reminderArray[myIndexG].name)"
        content.subtitle = ""
        content.body = ""
        content.badge = 1
        
        //trigger on a specific date and time
        var dateComponents = DateComponents()
                dateComponents.hour = 7
                dateComponents.minute = 30
        //        dateComponents.weekday = 2
        dateComponents.day = reminderArray[myIndexG].date
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let reference = String(noteReference)
        let noteID = "notificationID\(reference)"
        print(noteID)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: noteID, content: content, trigger: trigger)
        
        print("notification request: \(request)")
        
        //adding the notification to notification center
        if reminderArray.count != 0 {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    //CANCEL NOTIFICATIONS
    func cancelNotifications() {
        let reference = noteReference
        let noteID = "notificationID\(reference)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noteID])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
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
    

}

//ADD IMAGE TO LABEL
extension UILabel {
    
    func addTextWithImage(text: String, image: UIImage, imageBehindText: Bool, keepPreviousText: Bool) {
        let lAttachment = NSTextAttachment()
        lAttachment.image = image
        
        // 1pt = 1.32px
        let lFontSize = round(self.font.pointSize * 1.32)
        let lRatio = image.size.width / image.size.height
        
        lAttachment.bounds = CGRect(x: 0, y: ((self.font.capHeight - lFontSize) / 2).rounded(), width: lRatio * lFontSize, height: lFontSize)
        
        let lAttachmentString = NSAttributedString(attachment: lAttachment)
        
        if imageBehindText {
            let lStrLabelText: NSMutableAttributedString
            
            if keepPreviousText, let lCurrentAttributedString = self.attributedText {
                lStrLabelText = NSMutableAttributedString(attributedString: lCurrentAttributedString)
                lStrLabelText.append(NSMutableAttributedString(string: text))
            } else {
                lStrLabelText = NSMutableAttributedString(string: text)
            }
            
            lStrLabelText.append(lAttachmentString)
            self.attributedText = lStrLabelText
        } else {
            let lStrLabelText: NSMutableAttributedString
            
            if keepPreviousText, let lCurrentAttributedString = self.attributedText {
                lStrLabelText = NSMutableAttributedString(attributedString: lCurrentAttributedString)
                lStrLabelText.append(NSMutableAttributedString(attributedString: lAttachmentString))
                lStrLabelText.append(NSMutableAttributedString(string: text))
            } else {
                lStrLabelText = NSMutableAttributedString(attributedString: lAttachmentString)
                lStrLabelText.append(NSMutableAttributedString(string: text))
            }
            
            self.attributedText = lStrLabelText
        }
    }
    
}
