//
//  WelcomeViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/29/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import StoreKit
import Firebase

var localizedPriceString = String()

class WelcomeViewController: UIViewController, SKProductsRequestDelegate {
    
    @IBOutlet weak var textWithPrice: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    var product = SKProduct()
    var price = ""
    
    
    override func viewDidLayoutSubviews() {
        
        //Add rounded outline to save button
        getStartedButton.backgroundColor = .clear
        getStartedButton.layer.cornerRadius = 6
        getStartedButton.layer.borderWidth = 2
        getStartedButton.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if Auth.auth().currentUser?.uid == nil {
            loginButtonOutlet.setTitle("Login to Budge", for: .normal)
        } else {
            currentUserG = Auth.auth().currentUser!.uid
            loginButtonOutlet.setTitle("Sign Out", for: .normal)
        }
        
        //Hide navigation bar
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        
//        //IAP Code
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: "budge.subscription")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
            
            
        } else {
            print("please enable IAP")
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        
       
       
        //listen to notification to show/hide login/signout buttons
       NotificationCenter.default.addObserver(self, selector: #selector(setSignInOutButtons), name: NSNotification.Name(rawValue: "SignInOutButtons"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if price == "" {
            textWithPrice.text = "Try FREE for one week, then just $0.99/month. Cancel at any time."
        } else {
            textWithPrice.text = "Try FREE for one week, then just \(price)/month. Cancel at any time."
        }
        
    }
    
    
    
    @objc func setSignInOutButtons() {
        print("set login and sign out buttons")
        loginButtonOutlet.setTitle("Login to Budge", for: .normal)
    }
    
    
    @IBAction func getStartedButton(_ sender: Any) {
        
        signUpMode = true
        
        if Auth.auth().currentUser?.uid == nil {
            self.performSegue(withIdentifier: "goToSignUp", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToIAP", sender: self)
        }
         

    }
    

    @IBAction func loginButton(_ sender: Any) {
        
        if Auth.auth().currentUser?.uid == nil {
            signUpMode = false
            self.performSegue(withIdentifier: "goToSignUp", sender: self)
        } else {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                loginButtonOutlet.isHidden = false
                self.navigationItem.rightBarButtonItem = nil
                currentUserG = ""
                subscribedUser = false
                
                defaults.set(false, forKey: "SubscribedUser")
                defaults.set("", forKey: "CurrentUserG")
                
                loginButtonOutlet.setTitle("Login to Budge", for: .normal)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
        
        
    }
    
    
    @IBAction func signOutButton(_ sender: Any) {
        
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            for product in myProduct {
                print("product added")
                print(product.productIdentifier)
                print(product.localizedTitle)
                print(product.localizedDescription)
                print(product.price)
                print("price: \(price)")
               
            }
            price = product.localizedPrice
            print("price: \(price)")
            
        }
        
    }
    


}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
