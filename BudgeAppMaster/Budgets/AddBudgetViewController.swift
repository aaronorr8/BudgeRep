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
    //    let tempBudgetRemainingG = budgetRemainingG
    //    let tempTotalSpentG = totalSpentG
    let tempSubscribedUser = subscribedUser
    
    
    override func viewDidLayoutSubviews() {
        //Add underline to text fields
        budgetNameField.setUnderLine()
        budgetAmountField.setUnderLine()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setStyles()
        
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
        
        
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        editModeG = false
        
    }
    
    
    func setStyles() {
        
        saveButton.backgroundColor = Colors.buttonPrimaryBackground
        saveButton.setTitleColor(Colors.buttonPrimaryText, for: .normal)
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
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
        
        
        reloadBudgetViewCC = true
        
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
                "subscribedUser": subscribedUser
                
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



