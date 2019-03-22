//
//  AddSpendViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 7/12/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase


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
    let tempBudgetRemainingG = budgetRemainingG
    let tempTotalSpentG = totalSpentG
    
    override func viewDidLayoutSubviews() {
        //Add underline to text fields
        let bottomLineAmount = CALayer()
        bottomLineAmount.frame = CGRect(origin: CGPoint(x: 0, y:spendAmount.frame.height - 1), size: CGSize(width: spendAmount.frame.width, height:  1))
        bottomLineAmount.backgroundColor = UIColor.black.cgColor
        spendAmount.borderStyle = UITextField.BorderStyle.none
        spendAmount.layer.addSublayer(bottomLineAmount)
        
        //Add rounded outline to save button
        saveButton.backgroundColor = .clear
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
    }
    
    
    override func viewDidLoad() {
        
        print("Temp....\(tempBudgetRemainingG)")
        
        super.viewDidLoad()
        
        
        
        //Keyboard Shift (1/3)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        

        
//SET NAVIGATION BAR BUTTON AND TITLE COLOR
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //UINavigationBar.appearance().barTintColor = bgColorGradient1
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
        
        /*let remainingAmount = budgetRemainingG[myIndexG]
        if remainingAmount >= 0.0 {
            UINavigationBar.appearance().barTintColor = colorGreenC
        } else {
            UINavigationBar.appearance().barTintColor = colorRedC
        }*/
        //saveButton.backgroundColor = bgColorGradient1
        
        //saveButton.applyGradient(colours: [bgColorGradient1, bgColorGradient2])
       
        setNavigationBarColor()
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
        
        //REMINDER REFUND PRESET SETTING
        if presetRefundG == true {
            
        }
        
        
        //KEYBOARD ACCESSORY VIEW
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let toggleSwitch = UISwitch()

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
        
        let spaceAfterLastButton = view.frame.height - viewHistoryOutlet.frame.size.height/2 - viewHistoryOutlet.frame.origin.y
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

    
    func setNavigationBarColor() {
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = bgColorGradient1
        view.addSubview(barView)
        
        navigationController?.navigationBar.barTintColor = bgColorGradient1
    }
    
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
      
        print("editModeG: \(editModeG)")
        print("closeallG: \(closeAllG)")
        print("budgetNameG: \(budgetNameG)")
        //print("myIndex: \(budgetRemainingG[myIndexG])")
        
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

        
        let edit = UIAlertAction(title: "Edit Budget", style: .default) { action in
            self.closeKeyboard()
            editModeG = true
            print(editModeG)
            self.switchViewtoEdit()
        }
      
        
        let delete = UIAlertAction(title: "Delete Budget", style: .default) { action in
            self.closeKeyboard()
            self.deleteBudget()
            self.dismiss(animated: true, completion: nil)
        }
        

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
    
    
//SAVE BUTTON
    @IBAction func SaveButton(_ sender: Any) {
        
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
        budgetRemainingG[myIndexG] = (budgetAmountG[myIndexG] - totalSpentTemp)
        
        //print("\(month)/\(day)")
        //print("\(hour):\(minutes)")
            
        totalSpentG = totalSpentG + amount
        
        //Used for confirmation toast
        savedBudget = selectedBudget
        savedAmount = convertDoubleToCurency(amount: amount)
        

        saveToFireStore()
        self.dismiss(animated: true, completion: nil)
        
        
        //USED TO SUPPORT REMINDERS WITH LINKED BUDGETS
        presetAmountG = 0.0
        
//        self.dismiss(animated: true, completion: nil)
        
    }
    
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
                "totalSpent": totalSpentG
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    //revert values
                    budgetHistoryAmountG = self.tempBudgetHistoryAmountG
                    budgetNoteG = self.tempBudgetNoteG
                    budgetHistoryDateG = self.tempBudgetHistoryDateG
                    budgetHistoryTimeG = self.tempBudgetHistoryTimeG
                    budgetRemainingG = self.tempBudgetRemainingG
                    totalSpentG = self.tempTotalSpentG
                    
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
    
    

//DELETE BUDGET
    func deleteBudget() {
        
        //UPDATE BUDGETS
        let budgetNameTemp = budgetNameG[myIndexG]
        let totalSpentTemp = (budgetHistoryAmountG[budgetNameG[myIndexG]]?.reduce(0, +))!
        
        
        if budgetHistoryAmountG[budgetNameG[myIndexG]] != nil {
            budgetNameG.remove(at: myIndexG)
            budgetAmountG.remove(at: myIndexG)
            budgetRemainingG.remove(at: myIndexG)
            budgetHistoryAmountG.removeValue(forKey: budgetNameTemp)
            budgetHistoryDateG.removeValue(forKey: budgetNameTemp)
            budgetHistoryTimeG.removeValue(forKey: budgetNameTemp)
            budgetNoteG.removeValue(forKey: budgetNameTemp)
        }
     
        totalSpentG = totalSpentG - totalSpentTemp
        saveToFireStore()
//        setUserDefaults()
//        printBudgets()
    
    }
    
//    //MARK: PRINT BUDGETS
//    func printBudgets() {
//        print("Deleted!")
//        print("budgetNameG: \(budgetNameG)")
//        print("budgetAmountG: \(budgetAmountG)")
//        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
//        print("budgetHistoryDateG: \(budgetHistoryDateG)")
//        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
//        print("budgetRemainingG: \(budgetRemainingG)")
//        print("totalSpentG: \(totalSpentG)")
//        print("BREAK")
//    }
    
//    //Mark: SAVE USER DEFAULTS
//    func setUserDefaults() {
//        defaults.set(budgetHistoryAmountG, forKey: "BudgetHistoryAmount")
//        defaults.set(budgetNoteG, forKey: "BudgetNote")
//        defaults.set(budgetRemainingG, forKey: "BudgetRemaining")
//        defaults.set(budgetHistoryDateG, forKey: "BudgetHistoryDate")
//        defaults.set(budgetHistoryTimeG, forKey: "BudgetHistoryTime")
//        defaults.set(totalSpentG, forKey: "TotalSpent")
//    }
    
    //MARK: Save to FireStore
    
    
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
    
    
    
    
    @objc func switchViewtoEdit() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditBudget")
        self.present(viewController, animated: true)
        
        print("tap")
    }
    
    @objc func switchViewtoHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "BudgetHistory")
        self.present(viewController, animated: true)
        
        print("tap")
    }
    
    

}


