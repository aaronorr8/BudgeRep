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
    @IBOutlet weak var addUpdateButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
  
    
    
    var amt: Int = 0
    

    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        editModeG = false
       
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        if editModeG == false {
        
            print("Add Values")
            
//SAVE AS NEW BUDGET ITEM
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
//            saveUserDefaults()
            printBudgets()
            
            self.dismiss(animated: true, completion: nil)
            
        } else {
            
//EDIT BUDGET
            print("Update Values")
            
            //RETURN TO BUDGET VIEW
            if editModeG == true {
                
                //UPDATE BUDGET DATA
                let oldName = budgetNameG[myIndexG]
                
                budgetNameG[myIndexG] = budgetNameField.text!
                
                let amount = Double(amt/100) + Double(amt%100)/100
                budgetAmountG[myIndexG] = amount
                
                let historyArray = budgetHistoryAmountG[oldName]
                budgetHistoryAmountG.removeValue(forKey: budgetNameG[myIndexG])
                budgetHistoryAmountG[budgetNameField.text!] = historyArray
                
                let historyAmountArray = budgetHistoryAmountG[oldName]
                budgetHistoryAmountG.removeValue(forKey: oldName)
                budgetHistoryAmountG[budgetNameField.text!] = historyAmountArray
                
                let historyDateArray = budgetHistoryDateG[oldName]
                budgetHistoryDateG.removeValue(forKey: oldName)
                budgetHistoryDateG[budgetNameField.text!] = historyDateArray
                
                let historyTimeArray = budgetHistoryTimeG[oldName]
                budgetHistoryTimeG.removeValue(forKey: oldName)
                budgetHistoryTimeG[budgetNameField.text!] = historyTimeArray
                
                let totalSpent = budgetHistoryAmountG[budgetNameField.text!]?.reduce(0, +)
                budgetRemainingG[myIndexG] = (amount - totalSpent!)
                
                saveToFireStore()
//                saveUserDefaults()
                printBudgets()
                
                closeAllG = true
                editModeG = false
                
                self.dismiss(animated: true, completion: nil)

            }
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
    
    
    //MARK: Print Budgets
    func printBudgets() {
        print("budgetName: \(budgetNameG)")
        print("budgetAmount: \(budgetAmountG)")
        print("budgetHistoryAmount: \(budgetHistoryAmountG)")
        print("budgetNote: \(budgetNoteG)")
        print("budgetHistoryDate: \(budgetHistoryDateG)")
        print("budgetHistoryTime: \(budgetHistoryTimeG)")
        print("totalSpent: \(String(describing: totalSpentG))")
        print("budgetRemaining: \(budgetRemainingG)")
        print("BREAK")
    }
    
    
    //MARK Save UserDefaults
    func saveUserDefaults() {
        defaults.set(budgetNameG, forKey: "BudgetName")
        defaults.set(budgetAmountG, forKey: "BudgetAmount")
        defaults.set(budgetHistoryAmountG, forKey: "BudgetHistoryAmount")
        defaults.set(budgetNoteG, forKey: "BudgetNote")
        defaults.set(budgetHistoryDateG, forKey: "BudgetHistoryDate")
        defaults.set(budgetHistoryTimeG, forKey: "BudgetHistoryTime")
        defaults.set(budgetRemainingG, forKey: "BudgetRemaining")
    }
    
    override func viewDidLayoutSubviews() {
        
        if editModeG == true {
            print("view did layout subviews editModeG: \(editModeG)")
            navigationTitle.title = "Edit \(budgetNameG[myIndexG])"
            budgetNameField.text = budgetNameG[myIndexG]
            budgetAmountField.text = String(convertDoubleToCurency(amount: budgetAmountG[myIndexG]))
//            budgetAmountField.text = String(budgetAmountG[myIndexG])
            addUpdateButton.setTitle("Update", for: .normal)
            instructionsLabel.text = "Edit budget details:"
        } else {
            print("view did layout subviews editModeG: \(editModeG)")
            budgetNameField.becomeFirstResponder()
            navigationTitle.title = "New Budget"
            budgetNameField.placeholder = "Budget name"
            budgetAmountField.placeholder = "Budget amount"
            addUpdateButton.setTitle("Add", for: .normal)
            instructionsLabel.text = "Add budget details:"
        }
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //UINavigationBar.appearance().barTintColor = bgColorGradient1
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        
        budgetAmountField.delegate = self
        budgetAmountField.placeholder = updateAmount()
        
        setNavigationBarColor()
        
        
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
    
    //FOR NAVIGATION BAR GRADIENT
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
        
        UINavigationBar.appearance().tintColor = bgColorGradient1
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
