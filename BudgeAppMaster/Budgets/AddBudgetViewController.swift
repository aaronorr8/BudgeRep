//
//  AddBudgetViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 7/10/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase

var db:Firestore!

class AddBudgetViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var budgetNameField: UITextField!
    @IBOutlet weak var budgetAmountField: UITextField!
//    @IBOutlet weak var addUpdateButton: UIButton!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var navigationTitle: UINavigationItem!
 
    
    var amt: Int = 0
    
    //Create temperary arrays
    let tempBudgetNameG = budgetNameG
    let tempBudgetAmountG = budgetAmountG
    let tempBudetHistoryAmountG = budgetHistoryAmountG
    let tempBudgetNoteG = budgetNoteG
    let tempBudgetHistoryDateG = budgetHistoryDateG
    let tempBudgetHistoryTimeG = budgetHistoryTimeG
    let tempBudgetRemainingG = budgetRemainingG
//    let tempTotalSpentG = totalSpentG
    let tempSubscribedUser = subscribedUser
    

    override func viewDidLayoutSubviews() {
        //Add underline to text fields
        budgetNameField.setUnderLine()
        budgetAmountField.setUnderLine()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        budgetAmountField.delegate = self
        budgetAmountField.placeholder = updateAmount()
        
        if editModeG == true {
            print("view did layout subviews editModeG: \(editModeG)")
            navigationTitle.title = "Edit \(budgetNameG[myIndexG])"
            budgetNameField.text = budgetNameG[myIndexG]
            budgetAmountField.text = String(convertDoubleToCurency(amount: budgetAmountG[myIndexG]))
//            addUpdateButton.setTitle("Update", for: .normal)
        } else {
            print("view did layout subviews editModeG: \(editModeG)")
            navigationTitle.title = "Create New Budget"
            budgetNameField.placeholder = "Enter budget name"
            budgetAmountField.placeholder = "Enter budget amount"
//            addUpdateButton.setTitle("Save", for: .normal)
            budgetNameField.becomeFirstResponder()
        }
        
        
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        editModeG = false
       
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        if showIAP() == true {
            self.performSegue(withIdentifier: "goToIAP", sender: self)
        } else {
            
            if editModeG == false {
                
                
                //SAVE AS NEW BUDGET ITEM
                if budgetNameField.text != "" {
                    budgetNameG.append(budgetNameField.text!)
                    let amount = Double(amt/100) + Double(amt%100)/100
                    budgetAmountG.append(amount)
                    budgetHistoryAmountG[budgetNameField.text!] = []
                    budgetNoteG[budgetNameField.text!] = []
                    budgetHistoryDateG[budgetNameField.text!] = []
                    budgetHistoryTimeG[budgetNameField.text!] = []
                    let totalSpent = budgetHistoryAmountG[budgetNameField.text!]?.reduce(0, +)
                    budgetRemainingG.append(amount - totalSpent!)
                    
                    saveToFireStore()
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    print("EMPTY")
                    emptyTextAlert()
                }
            } else {
                
                //EDIT BUDGET
                
                
                //RETURN TO BUDGET VIEW
                if editModeG == true {
                    
                    if budgetNameField.text != "" {
                        
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
                        budgetRemainingG[myIndexG] = (amount - totalSpent!)
                        
                        saveToFireStore()
                        
                        closeAllG = true
                        editModeG = false
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        emptyTextAlert()
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
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
//            "totalSpent": totalSpentG,
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
                    budgetRemainingG = self.tempBudgetRemainingG
//                    totalSpentG = self.tempTotalSpentG
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
        print("budgetRemaining: \(budgetRemainingG)")
        print("subscribedUser: \(subscribedUser)")
        print("BREAK")
    }
    
    func emptyTextAlert() {
            let alert = UIAlertController(title: "Please enter a budget name.", message: nil, preferredStyle: .alert)
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
    
    func showIAP() -> Bool {
        
        var showIAPScreen = Bool()
        
        //        subscribedUser = defaults.bool(forKey: "SubscribedUser")
        //        registeredDate = defaults.object(forKey: "RegisteredDate") as! Date
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
        
        if minutes > 1 && subscribedUser == false {  //Minutes should be 10080 for 1 week
            //            self.performSegue(withIdentifier: "goToIAP", sender: self)
            showIAPScreen = true
        } else {
            showIAPScreen = false
        }
        print("showIAPScreen: \(showIAPScreen)")
        return showIAPScreen
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
