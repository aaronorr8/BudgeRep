//
//  AddBudgetViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 7/10/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase



class AddBudgetViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var budgetNameField: UITextField!
    @IBOutlet weak var budgetAmountField: UITextField!
    //    @IBOutlet weak var addUpdateButton: UIButton!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var amt: Int = 0
    
    //Create temperary arrays
    let tempBudgetNameG = budgetNameG
    let tempBudgetAmountG = budgetAmountG
    let tempBudetHistoryAmountG = budgetHistoryAmountG
    let tempBudgetNoteG = budgetNoteG
    let tempBudgetHistoryDateG = budgetHistoryDateG
    let tempBudgetHistoryTimeG = budgetHistoryTimeG
    let tempSubscribedUser = subscribedUser
    
    
    override func viewDidLayoutSubviews() {
        //Add underline to text fields
//        budgetNameField.setUnderLine()
//        budgetAmountField.setUnderLine()
        budgetNameField.textColor = Colors.themeAccentPrimary
        budgetNameField.backgroundColor = Colors.budgetViewCellBackground
        budgetNameField.layer.cornerRadius = 10
        budgetAmountField.textColor = Colors.themeAccentPrimary
        budgetAmountField.backgroundColor = Colors.budgetViewCellBackground
        budgetAmountField.layer.cornerRadius = 10
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setStyles()
        
        loadBudgetData()
        
        db = Firestore.firestore()
        
        budgetAmountField.delegate = self
        budgetAmountField.placeholder = updateAmount()
        
        if editModeG == true {
            print("view did layout subviews editModeG: \(editModeG)")
            self.title = "Edit budget"
            budgetNameField.text = budgetNameG[myIndexG]
            budgetAmountField.text = String(convertDoubleToCurency(amount: budgetAmountG[myIndexG]))
            saveButton.setTitle("Update budget", for: .normal)
        } else {
            print("view did layout subviews editModeG: \(editModeG)")
            self.title = "Create new budget"
            budgetNameField.placeholder = "Enter budget name"
            budgetAmountField.placeholder = "Enter budget amount"
            saveButton.setTitle("Create budget", for: .normal)
            budgetNameField.becomeFirstResponder()
        }
        
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
        
        
    }
    
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//
//            print("Keyboard height = \(keyboardHeight)")
//        }
//    }
    
    
    func loadBudgetData() {
        if currentUserG != "" {
            print("Load data from Firebase")
            fireStoreListener()
        } else {
            print("Load data from Defaults")
            loadUserDefaultsBudgets()
        }
    }
    
    //MARK: Load Data from Firebase
    func fireStoreListener() {
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("BudgetsVC Document data was empty.")
                        return
                    }
                    budgetNameG = document.get("budgetName") as! [String]
                    budgetAmountG = document.get("budgetAmount") as! [Double]
                    budgetHistoryAmountG = document.get("budgetHistoryAmount") as! [String : [Double]]
                    budgetNoteG = document.get("budgetNote") as! [String : [String]]
                    budgetHistoryDateG = document.get("budgetHistoryDate") as! [String : [String]]
                    budgetHistoryTimeG = document.get("budgetHistoryTime") as! [String : [String]]
                    subscribedUser = document.get("subscribedUser") as! Bool
                }
        }
        
        
    }
    
    //MARK: Load User Defaults
    func loadUserDefaultsBudgets() {
        if defaults.value(forKey: "budgetNameUD") != nil {budgetNameG = defaults.value(forKey: "budgetNameUD") as! [String]}
        if defaults.value(forKey: "budgetAmountUD") != nil {budgetAmountG = defaults.value(forKey: "budgetAmountUD") as! [Double]}
        if defaults.value(forKey: "budgetHistoryAmountUD") != nil {budgetHistoryAmountG = defaults.value(forKey: "budgetHistoryAmountUD") as! [String : [Double]]}
        if defaults.value(forKey: "budgetHistoryDateUD") != nil {budgetHistoryDateG = defaults.value(forKey: "budgetHistoryDateUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetHistoryTimeUD") != nil {budgetHistoryTimeG = defaults.value(forKey: "budgetHistoryTimeUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetNoteUD") != nil {budgetNoteG = defaults.value(forKey: "budgetNoteUD") as! [String: [String]]}
        print("budgetNameG: \(budgetNameG)")
        print("budgetAmountG: \(budgetAmountG)")
        print("budgetHistoryAmountG: \(budgetHistoryAmountG)")
        print("budgetHistoryDateG: \(budgetHistoryDateG)")
        print("budgetHistoryTimeG: \(budgetHistoryTimeG)")
        print("budgetNoteG: \(budgetNoteG)")
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        editModeG = false
        
    }
    
    
    func setStyles() {
        
        saveButton.backgroundColor = Colors.buttonPrimaryBackground
        saveButton.setTitleColor(Colors.buttonPrimaryText, for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        
//        //Navigation bar colors
//        navigationController?.navigationBar.barTintColor = Colors.navigationBarBackground
//        UINavigationBar.appearance().tintColor = Colors.navigationBarText
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:Colors.navigationBarText]
    }
    
    
    //MARK:Add New Budget
    @IBAction func saveButton(_ sender: Any) {
        if editModeG == false { //SAVE AS NEW BUDGET ITEM
            if budgetNameField.text == "" {
                emptyTextAlert()
            } else if budgetNameG.contains(budgetNameField.text ?? "") {
                budgetAlreadyExistsAlert()
            } else {
                
                if budgetNameField.text != "" {
                    budgetNameG.append(budgetNameField.text!)
                    let amount = Double(amt/100) + Double(amt%100)/100
                    budgetAmountG.append(amount)
                    budgetHistoryAmountG[budgetNameField.text!] = []
                    budgetNoteG[budgetNameField.text!] = []
                    budgetHistoryDateG[budgetNameField.text!] = []
                    budgetHistoryTimeG[budgetNameField.text!] = []
                    let totalSpent = budgetHistoryAmountG[budgetNameField.text!]?.reduce(0, +)
                    
                    save()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        } else { //EDIT BUDGET
            
            //RETURN TO BUDGET VIEW
            if editModeG == true {
                
                var tempBudgetNameArray = budgetNameG
                tempBudgetNameArray.remove(at: myIndexG)
                
                if budgetNameField.text == "" {
                    emptyTextAlert()
                } else if tempBudgetNameArray.contains(budgetNameField.text ?? "") {
                    budgetAlreadyExistsAlert()
                } else {
                    
                    //UPDATE BUDGET DATA
                    let oldName = budgetNameG[myIndexG]
                    
                    budgetNameG[myIndexG] = budgetNameField.text!
                    
                    
                    //Set Ammount if not edited
                    
                    var amount = Double(amt/100) + Double(amt%100)/100
                    
                    if amount == 0.0 {
                        amt = Int(budgetAmountG[myIndexG] * 100)
                        amount = Double(amt/100) + Double(amt%100)/100
                        budgetAmountG[myIndexG] = amount
                    } else {
                        budgetAmountG[myIndexG] = amount
                    }
                    
                    //Update Budget Name for History Dictionary
                    
                    //save values temperarily
                    let tempAmount = budgetHistoryAmountG[oldName]
                    let tempDate = budgetHistoryDateG[oldName]
                    let tempTime = budgetHistoryTimeG[oldName]
                    let tempNote = budgetNoteG[oldName]
                    let newName = budgetNameField.text!
                    
                    //remove key:value pair
                    budgetHistoryAmountG.removeValue(forKey: oldName)
                    budgetHistoryDateG.removeValue(forKey: oldName)
                    budgetHistoryTimeG.removeValue(forKey: oldName)
                    budgetNoteG.removeValue(forKey: oldName)
                    
                    //save values to new key
                    budgetHistoryAmountG[newName] = tempAmount
                    budgetHistoryDateG[newName] = tempDate
                    budgetHistoryTimeG[newName] = tempTime
                    budgetNoteG[newName] = tempNote
                    
                    
                    let totalSpent = budgetHistoryAmountG[budgetNameField.text!]?.reduce(0, +)
                    
                    save()
                    
                    closeAllG = true
                    editModeG = false
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
        
        
    }
    
    
    
    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
        }
    }
    
    
    //MARK: SAVE
    func save() {
        if currentUserG != "" {
            saveToFireStore()
            print("Save to FireStore")
        } else {
            saveToDefaults()
            print("Save to UserDefaults")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
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
                    budgetNameG = self.tempBudgetNameG
                    budgetAmountG = self.tempBudgetAmountG
                    budgetHistoryAmountG = self.tempBudetHistoryAmountG
                    budgetNoteG = self.tempBudgetNoteG
                    budgetHistoryDateG = self.tempBudgetHistoryDateG
                    budgetHistoryTimeG = self.tempBudgetHistoryTimeG
                    subscribedUser = self.tempSubscribedUser
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    
    
    
    
    
    
    //MARK: Print Budgets
    func printBudgets() {
        print("budgetName: \(budgetNameG)")
        print("budgetAmount: \(budgetAmountG)")
        print("budgetHistoryAmount: \(budgetHistoryAmountG)")
        print("budgetNote: \(budgetNoteG)")
        print("budgetHistoryDate: \(budgetHistoryDateG)")
        print("budgetHistoryTime: \(budgetHistoryTimeG)")
        //        print("totalSpent: \(String(describing: totalSpentG))")
        //        print("budgetRemaining: \(budgetRemainingG)")
        print("subscribedUser: \(subscribedUser)")
        print("BREAK")
    }
    
    func emptyTextAlert() {
        let alert = UIAlertController(title: "Please enter a budget name.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func budgetAlreadyExistsAlert() {
        let alert = UIAlertController(title: "Budget already exists.", message: "Pleaes give this budget a unique name.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                let alert = UIAlertController(title: "You don't make that much", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                budgetAmountField.text = ""
                
                amt = 0
                
            } else {
                budgetAmountField.text = updateAmount()
            }
            
            budgetAmountField.text = updateAmount()
        }
        
        if string == "" {
            amt = amt/10
            budgetAmountField.text = amt == 0 ? "" : updateAmount()
        }
        
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        
        //        budgetNameField.resignFirstResponder()
        //        budgetAmountField.becomeFirstResponder()
        return true
    }
    
    
}

extension UITextField {
    func setUnderLine() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    
}


class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 8,
        bottom: 0,
        right: 8
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}



