//
//  HistoryViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 9/5/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var budgetLabel: UILabel!
    var historyIndex = 0
    let budgetName = budgetNameG[myIndexG]
    var amt: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (budgetHistoryAmountG[budgetName]?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        
        var amount = budgetHistoryAmountG[budgetName]
        var note = budgetNoteG[budgetName]
        var date = budgetHistoryDateG[budgetName]
        var time = budgetHistoryTimeG[budgetName]
    
        cell.amountLabel.text = String(convertDoubleToCurency(amount: amount![indexPath.row]))
        cell.spendNote.text = note![indexPath.row]
        cell.dateLabel.text = String("\(date![indexPath.row]), \(time![indexPath.row])")

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped for index \(indexPath.row)")
            self.historyIndex = indexPath.row
            self.updateDialog()
            
        }
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
            self.historyIndex = indexPath.row
            self.deleteDialog()
        }
        
        edit.backgroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        delete.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        
        return [edit, delete]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        fireStoreListener()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "\(budgetName) History"
        self.title = "Spend Record"
      
    }
    
    @IBAction func closeButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateDialog() {
        
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter correct amount", message: "Update the amount here", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let saveRefund = UIAlertAction(title: "Save as Refund", style: .default) { (_) in
            
            //getting the input values from user
            let tempAmount = budgetHistoryAmountG[self.budgetName]![self.historyIndex]
            let amount = Double(self.amt/100) + Double(self.amt%100)/100
            self.amt = 0
            print("Update it")
            
            budgetHistoryAmountG[self.budgetName]?[self.historyIndex] = 0 - amount
            
            self.tableView.reloadData()
            
            //UPDATE TOTAL REMAINING IN BUDGET
            let totalSpent = (budgetHistoryAmountG[self.budgetName]?.reduce(0, +))!
            budgetRemainingG[myIndexG] = (budgetAmountG[myIndexG] - totalSpent)
            
            //UPDATE TOTAL SPENT IN ALL BUDGETS
//            totalSpentG = (totalSpentG - tempAmount) + amount
            
            self.saveToFireStore()

            
        }
        
        let savePurchase = UIAlertAction(title: "Save as Purchase", style: .default) { (_) in
            
            
            //getting the input values from user
            let tempAmount = budgetHistoryAmountG[self.budgetName]![self.historyIndex]
            let amount = Double(self.amt/100) + Double(self.amt%100)/100
            self.amt = 0
            print("Update it")
            
            budgetHistoryAmountG[self.budgetName]?[self.historyIndex] = amount
            
            self.tableView.reloadData()
            
            //UPDATE TOTAL REMAINING IN BUDGET
            let totalSpent = (budgetHistoryAmountG[self.budgetName]?.reduce(0, +))!
            budgetRemainingG[myIndexG] = (budgetAmountG[myIndexG] - totalSpent)
            
            //UPDATE TOTAL SPENT IN ALL BUDGETS
//            totalSpentG = (totalSpentG - tempAmount) + amount
            
            self.saveToFireStore()
            
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.amt = 0
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = self.updateAmount()
            
            alertController.isFirstResponder
            textField.keyboardType = .numberPad
            textField.textAlignment = NSTextAlignment.center
            
        }
        
        
        //adding the action to dialogbox
        alertController.addAction(savePurchase)
        alertController.addAction(saveRefund)
        alertController.addAction(cancelAction)
        
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteDialog() {
        
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Are you sure?", message: "Delete [details]", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmDelete = UIAlertAction(title: "Yes, Delete", style: .default) { (_) in
            
            //UPDATE TOTAL SPENT
            let amountToDelete = (budgetHistoryAmountG[self.budgetName]![self.historyIndex])
            
            budgetHistoryAmountG[self.budgetName]?.remove(at: self.historyIndex)
            budgetHistoryDateG[self.budgetName]?.remove(at: self.historyIndex)
            budgetNoteG[self.budgetName]?.remove(at: self.historyIndex)
            budgetHistoryTimeG[self.budgetName]?.remove(at: self.historyIndex)
            
//            totalSpentG = (totalSpentG - amountToDelete)
            
            budgetRemainingG[myIndexG] = budgetAmountG[myIndexG] - (budgetHistoryAmountG[self.budgetName]?.reduce(0, +))!
            
            self.saveToFireStore()
            self.tableView.reloadData()

        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmDelete)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            
            amt = amt * 10 + digit
            
            if amt > 1_000_000_000_00 {
                //let alert = UIAlertController(title: "You don't make that much", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                //present(alert, animated: true, completion: nil)
                
                textField.text = ""
                
                amt = 0
                
            } else {
                textField.text = updateAmount()
            }
            
            textField.text = updateAmount()
        }
        
        if string == "" {
            amt = amt/10
            textField.text = amt == 0 ? "" : updateAmount()
        }
        
        return false
    }
    
    //Use this function to open the AddSpend view
    func editSpend() {
        presetAmountG = budgetHistoryAmountG[budgetName]?[historyIndex] ?? 0.0
        presetNote = budgetNoteG[budgetName]?[historyIndex] ?? ""
        self.performSegue(withIdentifier: "EditSpend", sender: self)
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
//                "totalSpent": totalSpentG,
                "subscribedUser": subscribedUser
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
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
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    budgetNameG = document.get("budgetName") as! [String]
                    budgetAmountG = document.get("budgetAmount") as! [Double]
                    budgetHistoryAmountG = document.get("budgetHistoryAmount") as! [String : [Double]]
                    budgetNoteG = document.get("budgetNote") as! [String : [String]]
                    budgetHistoryDateG = document.get("budgetHistoryDate") as! [String : [String]]
                    budgetHistoryTimeG = document.get("budgetHistoryTime") as! [String : [String]]
                    budgetRemainingG = document.get("budgetRemaining") as! [Double]
//                    totalSpentG = document.get("totalSpent") as! Double
                    
                    print("Current data: \(data)")
                    
                    self.tableView.reloadData()
                    
            }
        }
    }

    

}
