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
    
    override func viewDidLayoutSubviews() {
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
                    amountSpentLabel.text = "Amount Refunded:"
                }
        
        let toggleText = UILabel()
        toggleText.text = "Save as refund: "
        
        //toolBar.setItems([flexibleSpace, toggleSwitch], animated: false)
        
        toolBar.setItems([flexibleSpace, UIBarButtonItem.init(customView: toggleText), UIBarButtonItem.init(customView: toggleSwitch)], animated: false)
        
        spendAmount.inputAccessoryView = toolBar
        spendNoteField.inputAccessoryView = toolBar
        
        
        
////SET NAVIGATION BAR GRADIENT
//        let gradient = CAGradientLayer()
//        let sizeLength = UIScreen.main.bounds.size.height * 2
//        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
//        gradient.frame = defaultNavigationBarFrame
//        gradient.colors = [bgColorGradient1.cgColor, bgColorGradient2.cgColor]
//        gradient.startPoint = CGPoint(x: 1, y: 1)
//        gradient.endPoint = CGPoint(x: 0, y: 0)
//
//        UINavigationBar.appearance().setBackgroundImage(self.image(fromLayer: gradient), for: .default)
    }
    
////FOR NAVIGATION BAR GRADIENT
//    func image(fromLayer layer: CALayer) -> UIImage {
//        UIGraphicsBeginImageContext(layer.frame.size)
//
//        layer.render(in: UIGraphicsGetCurrentContext()!)
//
//        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
//
//        UIGraphicsEndImageContext()
//
//        return outputImage!
//    }
    
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
            amountSpentLabel.text = "Amount Refunded:"
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
        
//        let viewHistory = UIAlertAction(title: "View Spend History", style: .default) { action in
//
//            self.switchViewtoHistory()
//            self.view.endEditing(true)
//        }
        
        let delete = UIAlertAction(title: "Delete Budget", style: .default) { action in
            self.closeKeyboard()
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
    
    
//SAVE BUTTON
    @IBAction func SaveButton(_ sender: Any) {
        
        //DISMISS KEYBOARD
        view.endEditing(true)
        
//        //GET DATE AND TIME
//        let date = Date()
//        let calendar = Calendar.current
//
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
//
//        let day = calendar.component(.day, from: date)
//        let month = calendar.component(.month, from: date)
        
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
            
        
//        setUserDefaults()
        saveToFireStore()
        
        
//PRINT BUDGETS
        print("budgetNameG: \(budgetNameG)")
        print("budgetAmountG: \(budgetAmountG)")
        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
        print("budgetNoteG: \(budgetNoteG)")
        print("budgetHistoryDateG: \(budgetHistoryDateG)")
        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
        print("totalSpentG: \(String(describing: totalSpentG))")
        print("budgetRemainingG: \(budgetRemainingG)")
        print("totalSpentG: \(totalSpentG)")
        print("BREAK")
        
        //USED TO SUPPORT REMINDERS WITH LINKED BUDGETS
        presetAmountG = 0.0
        
        self.dismiss(animated: true, completion: nil)
        
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
        printBudgets()
    
    }
    
    //MARK: PRINT BUDGETS
    func printBudgets() {
        print("Deleted!")
        print("budgetNameG: \(budgetNameG)")
        print("budgetAmountG: \(budgetAmountG)")
        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
        print("budgetHistoryDateG: \(budgetHistoryDateG)")
        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
        print("budgetRemainingG: \(budgetRemainingG)")
        print("totalSpentG: \(totalSpentG)")
        print("BREAK")
    }
    
    //Mark: SAVE USER DEFAULTS
    func setUserDefaults() {
        defaults.set(budgetHistoryAmountG, forKey: "BudgetHistoryAmount")
        defaults.set(budgetNoteG, forKey: "BudgetNote")
        defaults.set(budgetRemainingG, forKey: "BudgetRemaining")
        defaults.set(budgetHistoryDateG, forKey: "BudgetHistoryDate")
        defaults.set(budgetHistoryTimeG, forKey: "BudgetHistoryTime")
        defaults.set(totalSpentG, forKey: "TotalSpent")
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
                "totalSpent": totalSpentG
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
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


