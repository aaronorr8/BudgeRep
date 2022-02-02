//
//  AddSpendViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 7/12/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

var toastOverride = false //used to not show toast when deleting



//GRADIENT SUPPORT
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }
}

class AddSpendViewController: ViewController, UITextFieldDelegate{
    
    
    
    @IBOutlet weak var viewSpendHistoryButtonOutlet: UIButton!
    @IBOutlet weak var spendAmount: UITextField!
    @IBOutlet weak var selectedBudgetLabel: UILabel!
    @IBOutlet weak var selectBudgetField: UITextField!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var spendNoteField: UITextField!
    @IBOutlet weak var viewHistoryOutlet: UIButton!
    
    
  
    let buttonAttributesTrue : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor : UIColor.blue/*,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue*/]
    let buttonAttributesFalse : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor : UIColor.red,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
 
    var totalSpentTemp = 0.0
    var saveAsRefundToggle = false
    var amt: Int = 0
    var selectedIndex = 0
    var selectedBudget = budgetNameG[myIndexG]
    var spendNote = String()
    
    
    //Create temperary arrays
    let tempBudgetHistoryAmountG = budgetHistoryAmountG
    let tempBudgetNoteG = budgetNoteG
    let tempBudgetHistoryDateG = budgetHistoryDateG
    let tempBudgetHistoryTimeG = budgetHistoryTimeG
//    let tempBudgetRemainingG = budgetRemainingG
//    let tempTotalSpentG = totalSpentG
    
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      setStyles()
    
        
        
        
        //Keyboard Shift (1/3)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        

        self.title = budgetNameG[myIndexG]
        
        
        
        self.spendAmount.becomeFirstResponder()
        
        spendAmount.delegate = self
        //spendAmount.placeholder = updateAmount()
        spendAmount.placeholder = "$0.00"
        
        //USED TO SUPPORT REMINDERS WITH LINKED BUDGETS
        if presetAmountG != 0.0 {
            spendAmount.text = String(convertDoubleToCurency(amount: presetAmountG))
            amt = Int(presetAmountG) * 100
        }
        if presetNote != "" {
            spendNoteField.text = presetNote
        }
        
        
        //REMINDER REFUND PRESET SETTING
        if presetRefundG == true {
            
        }
        
        
        //KEYBOARD ACCESSORY VIEW
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = Colors.themeGreen

        toggleSwitch.addTarget(self, action: #selector(self.switchToggle), for: .valueChanged)
        
        //SET SWITCH. ON BY DEFAULT IF COMING FROM REMINDER
                if presetRefundG == false {
                    toggleSwitch.isOn = false
                } else {
                    toggleSwitch.isOn = true
                    saveAsRefundToggle = true
                    amountSpentLabel.text = "Refund Amount:"
                }
        
        let toggleText = UILabel()
        toggleText.text = "Save as refund: "
        
        //toolBar.setItems([flexibleSpace, toggleSwitch], animated: false)
        
        toolBar.setItems([flexibleSpace, UIBarButtonItem.init(customView: toggleText), UIBarButtonItem.init(customView: toggleSwitch)], animated: false)
        toggleSwitch.onTintColor = Colors.themeGreen
        
        spendAmount.inputAccessoryView = toolBar
        spendNoteField.inputAccessoryView = toolBar
        
     
        
        
    }
    
    
    
        
    //Keyboard Shift (2/3)
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //Keyboard Shift (3/3)
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let spaceAfterLastButton = view.frame.height - viewSpendHistoryButtonOutlet.frame.size.height/2 - viewSpendHistoryButtonOutlet.frame.origin.y
        let distance = spaceAfterLastButton - keyboardRect.height
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            if distance < 0 {
                view.frame.origin.y = distance - 20
            } else {
                view.frame.origin.y = 0
            }
        } else {
            view.frame.origin.y = 0
        }
    }

    
    
    
    //MARK: Set Styles
    func setStyles() {
        //Add underline to text fields
//        spendAmount.setUnderLine()
        spendNoteField.setUnderLine()
        spendAmount.textColor = Colors.themeBlack
        spendAmount.backgroundColor = Colors.themeGray
        spendAmount.layer.cornerRadius = 10
        
        
        
        
        
        //Add rounded outline to save button
        saveButton.backgroundColor = Colors.themeBlack
        saveButton.setTitleColor(Colors.themeWhite, for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        //        saveButton.layer.borderWidth = 2
        //        saveButton.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
        //Set color for View Spend History button
        viewSpendHistoryButtonOutlet.backgroundColor = .clear
        viewSpendHistoryButtonOutlet.setTitleColor(Colors.themeBlack, for: .normal)
        viewSpendHistoryButtonOutlet.tintColor = Colors.themeBlack
        viewSpendHistoryButtonOutlet.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

    
        
    }
    
    
    
    
    
    
    
//    func titleButton() {
//        let button =  UIButton(type: .custom)
//        button.setTitleColor(Colors.buttonPrimaryBackground, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        button.backgroundColor = .clear
//        button.setTitle(budgetNameG[myIndexG], for: .normal)
//        button.addTarget(self, action: #selector(tapOnTitleButton), for: .touchUpInside)
//        navigationItem.titleView = button
//    }
//
//    @objc func tapOnTitleButton() {
//        showActionSheet()
//    }
    
//SPEND/REFUND TOGGLE
    @objc func switchToggle() {
        //view.endEditing(true)
        print("toggle")
        
        if saveAsRefundToggle == false {
            saveAsRefundToggle = true
        } else {
            saveAsRefundToggle = false
        }
       
        if saveAsRefundToggle == true {
            amountSpentLabel.text = "Refund Amount:"
        } else {
            amountSpentLabel.text = "Amount Spent:"
        }
        
        
    }
    
   
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        createProgressFromValueArray()
        
        if closeAllG == true {
            self.dismiss(animated: true, completion: nil)
            closeAllG = false
        } else {
        
            if budgetNameG.count > 0 {
                //availableBalanceLabel.text = "Available balance: $\(budgetRemainingG[myIndexG])"
            } else {
                availableBalanceLabel.text = "$0.00"
            }
        }
        
    }
    
//MENU BUTTON AND ACTION SHEET
    @IBAction func editBudgetButton(_ sender: Any) {
        showActionSheet()
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        
//        let viewHistory = UIAlertAction(title: "View Spend History", style: .default) { action in
//            self.performSegue(withIdentifier: "goToSpendHistory", sender: self)
//        }
        
        let edit = UIAlertAction(title: "Edit Budget", style: .default) { action in
            editModeG = true
            print(editModeG)
            self.goToAddBudget()
        }
      
        
        let delete = UIAlertAction(title: "Delete Budget", style: .default) { action in
//            self.closeKeyboard()
            self.deleteBudget()
            self.dismiss(animated: true, completion: nil)
        }
        

//        actionSheet.addAction(viewHistory)
        actionSheet.addAction(edit)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        print("amount: \(amount)")
        return formatter.string(from: NSNumber(value: amount))
    }
    
    
//MARK: SAVE BUTTON
    @IBAction func SaveButton(_ sender: Any) {
        
//        if showIAP() == true {
//            self.performSegue(withIdentifier: "goToIAP", sender: self)
//        } else {
            
            if spendAmount.text != "" {
                
                
                
                //DISMISS KEYBOARD
                view.endEditing(true)
                
                
                //FORMAT DATE AND TIME
                let formatterDate = DateFormatter()
                let formatterTime = DateFormatter()
                formatterDate.locale = Locale(identifier: "en_US_POSIX")
                formatterTime.locale = Locale(identifier: "en_US_POSIX")
                formatterDate.dateFormat = "MMMM dd"
                formatterTime.dateFormat = "h:mma"
                //"h:mm a 'on' MMMM dd, yyyy"
                formatterTime.amSymbol = "am"
                formatterTime.pmSymbol = "pm"
                
                let dateString = formatterDate.string(from: Date())
                let timeString = formatterTime.string(from: Date())
                print(dateString)
                print(timeString)
                // "4:44 PM on June 23, 2016\n"
                //"h:mm a 'on' MMMM dd, yyyy"
                
                //SAVE AS REFUND IF TOGGLE IS TRUE
                var amount = Double(amt/100) + Double(amt%100)/100
                
                if saveAsRefundToggle == true {
                    amount = 0 - amount
                } else {
                    amount = abs(amount)
                }
                
                //SET SPEND NOTE IF EMPTY
                if spendNoteField.text == "" {
                    spendNote = ""
                } else {
                    spendNote = spendNoteField.text!
                }
                
                
                
                //ADD SPEND HISTORY TO BEGINNING OF ARRAY
                budgetHistoryAmountG[selectedBudget]?.insert(amount, at: 0)
                budgetNoteG[selectedBudget]?.insert(spendNote, at:0)
                budgetHistoryDateG[selectedBudget]?.insert(dateString, at: 0)
                budgetHistoryTimeG[selectedBudget]?.insert(timeString, at: 0)
                
                //CALCULATE REMAINING BUDGET
                totalSpentTemp = (budgetHistoryAmountG[selectedBudget]?.reduce(0, +))!
//                budgetRemainingG[myIndexG] = (budgetAmountG[myIndexG] - totalSpentTemp)
                
                //print("\(month)/\(day)")
                //print("\(hour):\(minutes)")
                
                //            totalSpentG = totalSpentG + amount
                
                //Used for confirmation toast
                savedBudget = selectedBudget
                savedAmount = convertDoubleToCurency(amount: amount)
                
                save()
                self.dismiss(animated: true, completion: nil)
                
                
                
                //USED TO SUPPORT REMINDERS WITH LINKED BUDGETS
                presetAmountG = 0.0
                
                
                
            } else {
                emptyTextAlert()
            }
            
//        }
        
        
        
//        askForReview()
        
    }
    
    
    //MARK:SAVE
    func save() {
        if currentUserG == "" {
            saveToDefaults()
            print("Saved to UserDefaults")
        } else {
            saveToFireStore()
            print("Saved to FireStore")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
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
                    //revert values
                    budgetHistoryAmountG = self.tempBudgetHistoryAmountG
                    budgetNoteG = self.tempBudgetNoteG
                    budgetHistoryDateG = self.tempBudgetHistoryDateG
                    budgetHistoryTimeG = self.tempBudgetHistoryTimeG
                    
                    showToast = true
                    toastSuccess = false
                } else {
                    print("Document successfully written!")
                    
                    showToast = true
                    toastSuccess = true
                    
                }
            }
        }
    }
    
    
    //MARK: Save to UserDefaults
    func saveToDefaults() {
        defaults.set(budgetNameG, forKey: "budgetNameUD")
        defaults.set(budgetAmountG, forKey: "budgetAmountUD")
        defaults.set(budgetHistoryAmountG, forKey: "budgetHistoryAmountUD")
        defaults.set(budgetHistoryDateG, forKey: "budgetHistoryDateUD")
        defaults.set(budgetHistoryTimeG, forKey: "budgetHistoryTimeUD")
        defaults.set(budgetNoteG, forKey: "budgetNoteUD")
    }
    
    

//DELETE BUDGET
    func deleteBudget() {
        
        //UPDATE BUDGETS
        let budgetNameTemp = budgetNameG[myIndexG]
        let totalSpentTemp = (budgetHistoryAmountG[budgetNameTemp]?.reduce(0, +))!
        
        
        if budgetHistoryAmountG[budgetNameG[myIndexG]] != nil {
            budgetNameG.remove(at: myIndexG)
            budgetAmountG.remove(at: myIndexG)
            budgetHistoryAmountG.removeValue(forKey: budgetNameTemp)
            budgetHistoryDateG.removeValue(forKey: budgetNameTemp)
            budgetHistoryTimeG.removeValue(forKey: budgetNameTemp)
            budgetNoteG.removeValue(forKey: budgetNameTemp)
        }
     
//        totalSpentG = totalSpentG - totalSpentTemp
        toastOverride = true
        save()

    
    }
    
    
    func createProgressFromValueArray() {
        progressFromValueArray.removeAll()
        for i in 0...budgetNameG.count - 1 {
                let selectedBudget = budgetNameG[i]
                let amountSpentInd = budgetHistoryAmountG[selectedBudget]?.reduce(0, +) ?? 0
                let budgetAmount = budgetAmountG[i]
                let percentSpent = Double(amountSpentInd/budgetAmount)
                progressFromValueArray.append(percentSpent)
            }
       
        print("progressFromValueArray \(progressFromValueArray)")
    }
    
   
    @IBAction func cancelButton(_ sender: Any) {
        presetAmountG = 0.0
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //SET PRESETS BACK TO DEFAULT
        presetRefundG = false
    }
    
    
//TEXT FIELD ALERT
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                let alert = UIAlertController(title: "You're crazy! You couldn't spend that much if you tried.", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                spendAmount.text = ""
                
                amt = 0
                
            } else {
                spendAmount.text = updateAmount()
            }
            
            spendAmount.text = updateAmount()
        }
        
        if string == "" {
            amt = amt/10
            spendAmount.text = amt == 0 ? "" : updateAmount()
        }
        
        return false
    }
    
    
    func emptyTextAlert() {
        let alert = UIAlertController(title: "Please enter an amount.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func goToAddBudget() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddBudgetNav")
        self.present(viewController, animated: true)
        
    }
    
    
    
    @objc func switchViewtoHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "BudgetHistory")
        self.present(viewController, animated: true)
        
        print("tap")
    }
    
    func showIAP() -> Bool {
        
        var showIAPScreen = Bool()
        
        if defaults.object(forKey: "RegisteredDate") != nil {
            registeredDate = defaults.object(forKey: "RegisteredDate") as! Date
        }
        
        iapDate = Date()
        
        let components = Calendar.current.dateComponents([.minute], from: registeredDate, to: iapDate)
        let minutes = components.minute ?? 0
        
        print("RegisteredDate: \(registeredDate)")
        print("iapDate: \(iapDate)")
        print("difference is \(components.minute ?? 0) minutes")
        print("SubscribedUser: \(subscribedUser)")
        
        print("minutes: \(minutes)")
        print("subscribed: \(subscribedUser)")
        
        if minutes >= freeMinutes && subscribedUser == false {  
            showIAPScreen = true
        } else {
            showIAPScreen = false
        }
        print("showIAPScreen: \(showIAPScreen)")
        return showIAPScreen
    }
    
 
    
    //MARK: App Review
      func askForReview() {
        
        var spendEntry = defaults.integer(forKey: "SpendEntry")
        
        print("SpendEntry: \(spendEntry)")
        
        spendEntry = spendEntry + 1
        
        print("SpendEntry: \(spendEntry)")
        
        defaults.set(spendEntry, forKey: "SpendEntry")
        
        
        if spendEntry > 5{
              SKStoreReviewController.requestReview()
          }
      }
    
    

}


