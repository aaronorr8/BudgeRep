//
//  IAPViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 4/11/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import SystemConfiguration

class IAPSubscriptionViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var tryForFreeLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var legalText: UILabel!
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [SKProduct]()
    var p = SKProduct()
    var product = SKProduct()
    var price = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        //IAP Code
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Add rounded outline to save button
        subscribeButton.backgroundColor = .clear
        subscribeButton.layer.cornerRadius = 6
        subscribeButton.layer.borderWidth = 2
        subscribeButton.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if price == "" {
            tryForFreeLabel.text = "Only $0.99 a month"
            
            //After the 1 week free trial this subscription automatically renews for $0.99 per month unless it is canceled at least 24 hours before the end of the trial period.
            
            legalText.text = "You can manage and cancel your subscriptions by going to your App Store account settings after purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period."
        } else {
            tryForFreeLabel.text = "Only \(price) a month"
            
            legalText.text = "You can manage and cancel your subscriptions by going to your App Store account settings after purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period."
        }
    }
    
    
    //MARK: SUBSCRIBE BUTTON
    @IBAction func subscribeButton(_ sender: Any) {
        
        startSpinner()

        //Check internet connection
        if checkNetworkConnection() {
            stopSpinner()
            print("You are connected, YEET!")
        } else {
            stopSpinner()
            self.Alert(Message: "Your device is not connected to the internet. Please try again.")
        }

        for product in list {
            let ProdID = product.productIdentifier
            if(ProdID == "budge.subscription") {
                p = product
                buyProduct()
            }
        }
        

    
        
        
    }
    
    //MARK: Product Request
    
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
                
                list.append(product)
        }
            
//            price = product.localizedPrice
//            print("localized price: \(price)")
            
        
        
            
            
            
            // Get the receipt if it's available
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

                do {
                    let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                    print(receiptData)

                    let receiptString = receiptData.base64EncodedString(options: [])

                    // Read receiptData
                }
                catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
            }

            
    }
        
        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            print("transactions restored")
            for transaction in queue.transactions {
                let t: SKPaymentTransaction = transaction
                let prodID = t.payment.productIdentifier as String
            
                switch prodID {
                case "budge.subscription":
                    print("Subscribe")
//                    unlockApp()
                default:
                    print("IAP not found")
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error as Any)
            
            switch trans.transactionState {
            case .purchased:
                let prodID = p.productIdentifier
                switch prodID {
                case "budge.subscription":
                    print("Subscribed")
                    stopSpinner()
                    unlockApp()
                default:
                    print("IAP not found")
                }
                queue.finishTransaction(trans)
                
            case .restored:
                print("Restore app purchase now!")
                stopSpinner()
                unlockApp()
                showRestoredAlert()
                
            case .failed:
                print("buy error")
                stopSpinner()
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
    }
    
    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    

    
    @IBAction func restorePurchase(_ sender: Any) {
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        print("Restore")
        
    }
    
    @IBAction func termsButton(_ sender: Any) {
        guard let url = URL(string: "https://budgeapp.wixsite.com/budge/terms-of-use") else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func privacyButton(_ sender: Any) {
        guard let url = URL(string: "https://budgeapp.wixsite.com/budge/privacy-policy") else { return }
        UIApplication.shared.open(url)
    }
    
    

    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
    //MARK: UNLOCK APP
    func unlockApp() {
        subscribedUser = true
        save()
        closeIAPScreen()
    }
    
    func closeIAPScreen() {
        print("closeIAPScreen called")
        //not subscribed, not signed in -> intro>subscribe>signup>instructions
        if currentUserG == "" {
            hideBackButton = true
            performSegue(withIdentifier: "goToSignUp", sender: self)
        } else {
            performSegue(withIdentifier: "goToSyncInstructions", sender: self)
        }
        
        
    }
    
    
//    func showSignUpAndSync() {
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowSignUpAndSync"), object: nil)
//    }
    
    
    
    func convertDoubleToCurency(amount: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        return numberFormatter.string(from: NSNumber(value: amount))!
        
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
    
    //MARK: SAVE TO FIREBASE
    func saveToFireStore() {
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("budgets").document(userID).setData([
                "budgetName": budgetNameG,
                "budgetAmount": budgetAmountG,
                "budgetHistoryAmount": budgetHistoryAmountG,
                "budgetNote": budgetNoteG,
                "budgetHistoryDate": budgetHistoryDateG,
                "budgetHistoryTime": budgetHistoryTimeG,
//                "budgetRemaining": budgetRemainingG,
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
    
    //MARK: SAVE TO DEFAULTS
    func saveToDefaults() {
        defaults.set(subscribedUser, forKey: "SubscribedUser")
    }
    
    
    func showRestoredAlert() {
        let alert = UIAlertController(title: "Budge Subscription Restored!", message:
        "You now have full access to the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
//            self.unlockApp()
        }))
    
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
    
    func checkNetworkConnection() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    func Alert (Message: String){
        
        let alert = UIAlertController(title: "No Internet Connection", message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    

    
    
}
