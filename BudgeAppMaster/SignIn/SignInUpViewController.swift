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
        
       
        
        //Add underline to text fields
        emailField.setUnderLine()
        passwordField.setUnderLine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //If users is logged in but not subscribed
        if currentUserG != "" {
            //notification to load login buttons
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignInOutButtons"), object: nil)
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setModeText()
       
    
        
        //Keyboard Shift (1/3)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        
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
                            
                            print("set currentUserG defaults to \(currentUserG)")
                            defaults.set(currentUserG, forKey: "CurrentUserG")
                        }
                        
                        print("Signup Successful!")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                        self.performSegue(withIdentifier: "goToIAP", sender: self)
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
                            
                            print("set currentUserG defaults to \(currentUserG)")
                            defaults.set(currentUserG, forKey: "CurrentUserG")
                        }
                     
                        
                        print("Login successful!!")
//                        self.fireStoreListener()
//                        self.getFirestoreData()
                        self.newGetFireStoreData()
                        
                        
                        
                    }
                }
                
                self.view.endEditing(true)
                
            }
        } else {
            stopSpinner()
            emptyEmailFieldAlert()
        }
        
        
        
        
    }
    
    func getUserData() {
       
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
            instructionLabel.text = "Create an Account"
            switchModes.setTitle("Login Instead", for: .normal)
            pigImage.image = #imageLiteral(resourceName: "PigRight")
            forgotPasswordOutlet.isHidden = true
        } else {
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
//                        defaults.set(true, forKey: "SubscribedUser")
                        self.performSegue(withIdentifier: "goToBudgets", sender: self)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "goToIAP", sender: self)
                    }
                } else {
                    print("AppDelegate: Document does not exist in cache")
                    self.performSegue(withIdentifier: "goToIAP", sender: self)
                }
            }
        } else {
            print("AppDelegate: No UserID Found")
            currentUserG = ""
        }
        
    }
    
    
    func newGetFireStoreData() {
        db = Firestore.firestore()
        
         if Auth.auth().currentUser?.uid != nil {
             currentUserG = Auth.auth().currentUser!.uid
             print("AppDelegate: currentUserG: \(currentUserG)")
             
             let docRef = db.collection("budgets").document(currentUserG)
             
             docRef.getDocument(source: .cache) { (document, error) in
                 if let document = document {
                     let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                     print("Cached document data: \(dataDescription)")
                     
                     if let subStatusFromDoc = document.get("subscribedUser") {
                         subscribedUser = subStatusFromDoc as! Bool
                         print("LogIn screen: subscribedUser: \(subscribedUser)")
                     } else {
                         print("Login screen: Couldn't get subscriber status")
                     }
                 } else {
                     print("Login screen: Document does not exist in cache")
                 }
                 
                 if subscribedUser == true {
                    self.performSegue(withIdentifier: "goToBudgets", sender: self)
                 } else {
                    self.performSegue(withIdentifier: "goToIAP", sender: self)
                 }
                 
                 
             }
         } else {
             print("Login screen: Could not get userID")
         }
    }
    
    
   
    
  
    

}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
