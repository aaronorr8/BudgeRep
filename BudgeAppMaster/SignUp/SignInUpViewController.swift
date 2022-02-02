//
//  SignInUpViewController.swift
//  Budget App
//
//  Created by Aaron Orr on 3/1/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import Firebase

var signUpMode = true
var isWelcomeScreenLogin = false
var needToCombineBudgets = false

//var tempFirebaseBudgetNameG = [String]()
//var tempFirebaseBudgetAmountG = [Double]()
//var tempFirebaseBudgetHistoryAmountG = [String : [Double]]()
//var tempFirebaseBudgetNoteG = [String : [String]]()
//var tempFirebaseBudgetHistoryDateG = [String : [String]]()
//var tempFirebaseBudgetHistoryTimeG = [String : [String]]()

var firebaseBudgetNameG = [String]()
var firebaseBudgetAmountG = [Double]()
var firebaseBudgetHistoryAmountG = [String : [Double]]()
var firebaseBudgetNoteG = [String : [String]]()
var firebaseBudgetHistoryDateG = [String : [String]]()
var firebaseBudgetHistoryTimeG = [String : [String]]()

var defaultsBudgetNameG = [String]()
var defaultsBudgetAmountG = [Double]()
var defaultsBudgetHistoryAmountG = [String : [Double]]()
var defaultsBudgetHistoryDateG = [String: [String]]()
var defaultsBudgetHistoryTimeG = [String: [String]]()
var defaultsBudgetNoteG = [String: [String]]()




class SignInUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBOutlet weak var switchModes: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var pigImage: UIImageView!
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    
    var errorText = String()
    
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLayoutSubviews() {
        
        
        signInButtonOutlet.backgroundColor = Colors.themeBlack
        signInButtonOutlet.setTitleColor(Colors.themeWhite, for: .normal)
        signInButtonOutlet.layer.cornerRadius = signInButtonOutlet.frame.height / 2
        
        emailField.textColor = Colors.themeBlack
        emailField.backgroundColor = Colors.themeGray
        emailField.layer.cornerRadius = 10
        
        passwordField.textColor = Colors.themeBlack
        passwordField.backgroundColor = Colors.themeGray
        passwordField.layer.cornerRadius = 10
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setModeText()
        
        
        
        //Keyboard Shift (1/3)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if isWelcomeScreenLogin == true {
            switchModes.isHidden = true
            signUpMode = false
            signInButtonOutlet.setTitle("Login", for: .normal)
            forgotPasswordOutlet.isHidden = false
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if hideBackButton == true {
            hideBackButton = false
            self.navigationItem.setHidesBackButton(true, animated: true)
        }
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
        
        let spaceAfterLastButton = view.frame.height - switchModes.frame.size.height/2 - switchModes.frame.origin.y
        let distance = spaceAfterLastButton -  keyboardRect.height
        
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
    
    
    func hideKeyboard() {
        passwordField.resignFirstResponder()
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        
        if isWelcomeScreenLogin == true {
            self.navigationController!.popToRootViewController(animated: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "generic"), object: nil)
        
        isWelcomeScreenLogin = false
    }
    
    
    
    //MARK: SignIn Button Tapped
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        startSpinner()
        
        if isValidEmail(testStr: email!) == true {
            
            //        if emailField.text != "" {
            
            if signUpMode == true {
                //MARK: SIGNUP MODE
                Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                    if error != nil {
                        //ERROR STATE
                        self.errorText = error?.localizedDescription ?? "Unable to signup at this time. Please try again."
                        self.stopSpinner()
                        self.signUpAlert()
                        print(error!)
                    } else {
                        //SUCCESS STATE
                        registeredDate = Auth.auth().currentUser?.metadata.creationDate! ?? Date()
                        defaults.set(registeredDate, forKey: "RegisteredDate")
                        
                        self.stopSpinner()
                        
                        goToMain = true
                        
                        if Auth.auth().currentUser?.uid != nil {
                            print("UserID: \(Auth.auth().currentUser?.uid)")
                            currentUserG = Auth.auth().currentUser!.uid
                            print("currentUserG: \(currentUserG)")
                        }
                        
                        print("Signup Successful!")
                        self.transferData()
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                        self.goToNextScreen()
                        
                    }
                }
            } else {
                //MARK: LOGIN MODE
                
                Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                    if error != nil {
                        //ERROR STATE
                        self.errorText = error?.localizedDescription ?? "Unable to login at this time. Please try again."
                        self.stopSpinner()
                        self.loginAlert()
                        print(error?.localizedDescription)
                    } else {
                        //SUCCESS STATE
                        registeredDate = Auth.auth().currentUser?.metadata.creationDate! ?? Date()
                        defaults.set(registeredDate, forKey: "RegisteredDate")
                        self.stopSpinner()
                        
                        goToMain = true
                        
                        if Auth.auth().currentUser?.uid != nil {
                            print("UserID: \(Auth.auth().currentUser?.uid)")
                            currentUserG = Auth.auth().currentUser!.uid
                            print("currentUserG: \(currentUserG)")
                        }
                        
                        print("Login successful!!")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
//                        self.saveDefaultsToFirebaseIfNeeded()
                        self.goToNextScreen()
                        
                        
                        
                    }
                }
                
                self.view.endEditing(true)
                
                
            }
        } else {
            stopSpinner()
            emptyEmailFieldAlert()
        }
        
        
    }
    
    
    
    
    func showWarningIfLosingBudgets() {
        if currentUserG == "" {
            if budgetNameG.isEmpty == false {
                let alert = UIAlertController(title: "WARNING!", message: "Because you already have budgets saved to your account and also created budgets when not logged in, the budgets created when not logged in will be replaced by the budgets saved to your account when you were signed in. Do you want to continue?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes, continue", style: UIAlertAction.Style.default, handler: { _ in
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getUserData() {
        
    }
    
    
    //MARK: MOVE DEFAULTS TO FIRESTORE
    func transferData() {
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
                    print("Transfer Data, Error writing document: \(err)")
                } else {
                    print("Transfer data to Firebase")
                    print("Transfer Data, Document successfully written!")
                    self.clearDefaults()
                }
            }
        }
    }
    
    func clearDefaults() {
        budgetNameG.removeAll()
        budgetAmountG.removeAll()
        budgetHistoryAmountG.removeAll()
        budgetHistoryDateG.removeAll()
        budgetHistoryTimeG.removeAll()
        budgetNoteG.removeAll()
        
        defaults.set(budgetNameG, forKey: "budgetNameUD")
        defaults.set(budgetAmountG, forKey: "budgetAmountUD")
        defaults.set(budgetHistoryAmountG, forKey: "budgetHistoryAmountUD")
        defaults.set(budgetHistoryDateG, forKey: "budgetHistoryDateUD")
        defaults.set(budgetHistoryTimeG, forKey: "budgetHistoryTimeUD")
        defaults.set(budgetNoteG, forKey: "budgetNoteUD")
    }
    
    
    
    
    
    
    @IBAction func switchModes(_ sender: Any) {
        if signUpMode == true {
            signUpMode = false
        } else {
            signUpMode = true
        }
        setModeText()
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        forgotPasswordAlert()
    }
    
    
    
    func emptyEmailFieldAlert() {
        let alert = UIAlertController(title: "Please enter a valid email address.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetPasswordAlert() {
        let alert = UIAlertController(title: "Please check your email.", message: "You should receive a link to reset your password soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func forgotPasswordAlert() {
        var email = self.emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let alert = UIAlertController(title: "Reset password?", message: nil, preferredStyle: .alert)
        
        //Add text field
        alert.addTextField { (textField) -> Void in
            if email == "" {
                textField.placeholder = "Enter email"
            } else {
                textField.text = email!
            }
        }
        
        alert.addAction(UIAlertAction(title: "Reset now", style: UIAlertAction.Style.default, handler: { _ in
            
            email = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if self.isValidEmail(testStr: email!) == true {
                
                Auth.auth().sendPasswordReset(withEmail: email!) { error in
                    if error == nil {
                        self.resetPasswordAlert()
                    } else {
                        print("reset password error: \(String(describing: error))")
                    }
                }
            } else {
                self.emptyEmailFieldAlert()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func loginAlert() {
        let alert = UIAlertController(title: errorText, message: nil, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func signUpAlert() {
        let alert = UIAlertController(title: errorText, message: nil, preferredStyle: .alert)
        //        let alert = UIAlertController(title: "Oops! Looks like there's already an account with that email.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func startSpinner() {
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopSpinner() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func setModeText() {
        if signUpMode == true {
            signInButtonOutlet.setTitle("Sign Up", for: .normal)
            instructionLabel.text = "Create an Account"
            switchModes.setTitle("Login Instead", for: .normal)
            pigImage.image = #imageLiteral(resourceName: "PigRight")
            forgotPasswordOutlet.isHidden = true
        } else {
            signInButtonOutlet.setTitle("Login", for: .normal)
            instructionLabel.text = "Login to Budge"
            switchModes.setTitle("SignUp Instead", for: .normal)
            pigImage.image = #imageLiteral(resourceName: "PigLeft")
            forgotPasswordOutlet.isHidden = false
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    
    //MARK: Get Firestore Data
    func getFirestoreData () {
        
        db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.uid {
            currentUserG = Auth.auth().currentUser!.uid
            print("AppDelegate: currentUserG: \(currentUserG)")
            
            let docRef = db.collection("budgets").document(userID)
            
            // Force the SDK to fetch the document from the cache. Could also specify
            // FirestoreSource.server or FirestoreSource.default.
            docRef.getDocument(source: .cache) { (document, error) in
                if let document = document {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("AppDelegate: Cached document data: \(dataDescription)")
                    subscribedUser = document.get("subscribedUser") as! Bool
                    print("AppDelegate: subscribedUser: \(subscribedUser)")
                    if subscribedUser == true {
                        print("set subscribedUser defaults to true")
                        defaults.set(true, forKey: "SubscribedUser")
                    } else {
                    }
                } else {
                    print("AppDelegate: Document does not exist in cache")
                }
            }
        } else {
            print("AppDelegate: No UserID Found")
            currentUserG = ""
        }
        
    }
    
    
    func goToNextScreen() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func saveDefaultsToFirebaseIfNeeded() {
        print("saveDefaultsToFirebaseIfNeeded function start")
        
        if defaults.value(forKey: "budgetNameUD") != nil {
            defaultsBudgetNameG = defaults.value(forKey: "budgetNameUD") as! [String]}
        if defaults.value(forKey: "budgetAmountUD") != nil {
            defaultsBudgetAmountG = defaults.value(forKey: "budgetAmountUD") as! [Double]}
        if defaults.value(forKey: "budgetHistoryAmountUD") != nil {
            defaultsBudgetHistoryAmountG = defaults.value(forKey: "budgetHistoryAmountUD") as! [String : [Double]]}
        if defaults.value(forKey: "budgetHistoryDateUD") != nil {
            defaultsBudgetHistoryDateG = defaults.value(forKey: "budgetHistoryDateUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetHistoryTimeUD") != nil {
            defaultsBudgetHistoryTimeG = defaults.value(forKey: "budgetHistoryTimeUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetNoteUD") != nil {
            defaultsBudgetNoteG = defaults.value(forKey: "budgetNoteUD") as! [String: [String]]}
        
        if defaultsBudgetNameG.isEmpty == false {
            print("Save defaults to Firebase")
            budgetNameG = defaultsBudgetNameG
            budgetAmountG = defaultsBudgetAmountG
            budgetHistoryAmountG = defaultsBudgetHistoryAmountG
            budgetHistoryDateG = defaultsBudgetHistoryDateG
            budgetHistoryTimeG = defaultsBudgetHistoryTimeG
            budgetNoteG = defaultsBudgetNoteG
            
            saveToFireStore()
            
        } else {
            print("Don't save defaults to Firebase")
        }
        
        print("Defaults data")
        print(defaultsBudgetNameG)
        print(defaultsBudgetAmountG)
        print(defaultsBudgetHistoryAmountG)
        print(defaultsBudgetHistoryDateG)
        print(defaultsBudgetHistoryTimeG)
        print(defaultsBudgetNoteG)
        
        print("saveDefaultsToFirebaseIfNeeded function end")
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
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    
 
/*
    //MARK: Combine budgets if needed
    
    func combineDefaultsAndFirebaseData() {
        needToCombineBudgets = true
//        getDefaultsData()
//        getFirebaseData()
//        renameFirebaseData()
//        combineData()
//        saveToFirebase()
    }
    
    
    //1
    func getDefaultsData(){
        print("getDefaultsData function start")
        
        if defaults.value(forKey: "budgetNameUD") != nil {
            defaultsBudgetNameG = defaults.value(forKey: "budgetNameUD") as! [String]}
        if defaults.value(forKey: "budgetAmountUD") != nil {
            defaultsBudgetAmountG = defaults.value(forKey: "budgetAmountUD") as! [Double]}
        if defaults.value(forKey: "budgetHistoryAmountUD") != nil {
            defaultsBudgetHistoryAmountG = defaults.value(forKey: "budgetHistoryAmountUD") as! [String : [Double]]}
        if defaults.value(forKey: "budgetHistoryDateUD") != nil {
            defaultsBudgetHistoryDateG = defaults.value(forKey: "budgetHistoryDateUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetHistoryTimeUD") != nil {
            defaultsBudgetHistoryTimeG = defaults.value(forKey: "budgetHistoryTimeUD") as! [String: [String]]}
        if defaults.value(forKey: "budgetNoteUD") != nil {
            defaultsBudgetNoteG = defaults.value(forKey: "budgetNoteUD") as! [String: [String]]}
        
        print("Defaults data")
        print(defaultsBudgetNameG)
        print(defaultsBudgetAmountG)
        print(defaultsBudgetHistoryAmountG)
        print(defaultsBudgetHistoryDateG)
        print(defaultsBudgetHistoryTimeG)
        print(defaultsBudgetNoteG)
        
        print("getDefaultsData function end")
    }
    

    
    
    
    //2
    func getFirebaseData() {
        print("getFirebaseData function start")
        
        if let userID = Auth.auth().currentUser?.uid {
            print("userID = \(userID)")
            
            let docRef = db.collection("budgets").document(userID)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }


//        firebaseBudgetNameG = document.get("budgetName") as! [String]
//        firebaseBudgetAmountG = document.get("budgetAmount") as! [Double]
//        firebaseBudgetHistoryAmountG = document.get("budgetHistoryAmount") as! [String : [Double]]
//        firebaseBudgetNoteG = document.get("budgetNote") as! [String : [String]]
//        firebaseBudgetHistoryDateG = document.get("budgetHistoryDate") as! [String : [String]]
//        firebaseBudgetHistoryTimeG = document.get("budgetHistoryTime") as! [String : [String]]

        print(firebaseBudgetNameG)
        print(firebaseBudgetAmountG)
        print(firebaseBudgetHistoryAmountG)
        print(firebaseBudgetHistoryDateG)
        print(firebaseBudgetHistoryTimeG)
        print(firebaseBudgetNoteG)
        
        print("getFirebaseData function end")
    }
    
    //3
    func renameFirebaseData() {
        print("renameFirebaseData function start")
        
        let count = firebaseBudgetNameG.count - 1
        
        for i in 0...count {
            firebaseBudgetNameG.append("\(firebaseBudgetNameG[i]) (Recovered)")
            firebaseBudgetHistoryAmountG.switchKey(fromKey: firebaseBudgetNameG[i], toKey: "\(firebaseBudgetNameG[i]) (Recovered)")
            firebaseBudgetNoteG.switchKey(fromKey: firebaseBudgetNameG[i], toKey: "\(firebaseBudgetNameG[i]) (Recovered)")
            firebaseBudgetHistoryDateG.switchKey(fromKey: firebaseBudgetNameG[i], toKey: "\(firebaseBudgetNameG[i]) (Recovered)")
            firebaseBudgetHistoryTimeG.switchKey(fromKey: firebaseBudgetNameG[i], toKey: "\(firebaseBudgetNameG[i]) (Recovered)")
        }
        
        print("FIREBASE DATA:")
        print(firebaseBudgetNameG)
        print(firebaseBudgetAmountG)
        print(firebaseBudgetHistoryAmountG)
        print(firebaseBudgetNoteG)
        print(firebaseBudgetHistoryDateG)
        print(firebaseBudgetHistoryTimeG)
        print("DEFAULTS DATA:")
        print(defaultsBudgetNameG)
        print(defaultsBudgetAmountG)
        print(defaultsBudgetHistoryAmountG)
        print(defaultsBudgetHistoryDateG)
        print(defaultsBudgetHistoryTimeG)
        print(defaultsBudgetNoteG)
        
        print("renameFirenase Data function end")
    }
    
    //4
    func combineData() {
        print("combineData function start")
        
        budgetNameG = defaultsBudgetNameG + firebaseBudgetNameG
        print("combined budgetNameG: \(budgetNameG)")
        
        budgetAmountG = defaultsBudgetAmountG + firebaseBudgetAmountG
        print("combined budgetAmountG: \(budgetAmountG)")
        
        budgetHistoryAmountG = defaultsBudgetHistoryAmountG.merging(firebaseBudgetHistoryAmountG) { (current, _) in current }
        print("combined budgetHistoryAmountG: \(defaultsBudgetHistoryAmountG)")
        
        budgetNoteG = defaultsBudgetNoteG.merging(firebaseBudgetNoteG) { (current, _) in current }
        print("combined budgetNoteG: \(budgetNoteG)")
        
        budgetHistoryDateG = defaultsBudgetHistoryDateG.merging(firebaseBudgetHistoryDateG) { (current, _) in current }
        print("combined budgetHistoryDateG: \(defaultsBudgetHistoryDateG)")
        
        budgetHistoryTimeG = defaultsBudgetHistoryTimeG.merging(firebaseBudgetHistoryTimeG) { (current, _) in current }
        print("combined budgetHistoryTimeG: \(budgetHistoryTimeG)")
        
        print("combineData function end")
    }
    
    //5
    func saveToFirebase() {
        print("saveToFirebase function start")
        
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
                } else {
                    print("Document successfully written!")
                }
            }
        }
        
        print("saveToFirebase function end")
    }
    
 */
    
}
    



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}


//"Because you already have budgets saved to your account and also created budgets when not logged in, the budgets created when not logged in will be replaced by the budgets saved to your account when you were signed in. Do you want to continue?"
