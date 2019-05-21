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

class IAPViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var benefitList: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var tryForFreeLabel: UILabel!
    @IBOutlet weak var benefitView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var list = [SKProduct]()
    var p = SKProduct()
    var product = SKProduct()
    
    
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
        
        let arrayString = [
            "Easily create your own budgets and track spending.",
            "Sync your budget with anyone you choose. Makes sharing a budget super easy!",
            "Set reminders so you never miss a bill's due date."
        ]
        
        benefitList.attributedText = add(stringList: arrayString, font: benefitList.font, bullet: "\u{2022}")
        self.benefitView.addSubview(benefitList)
    }
    
    override func viewDidLayoutSubviews() {
//        //Show or hide close button
//        if hideCloseButton == true {
//            closeButton.isHidden = true
//        } else {
//            closeButton.isHidden = false
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        hideCloseButton = true
    }
    
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
        
        
//        self.dismiss(animated: true, completion: nil)
        
    
        
        
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
                
                list.append(product)
        }
            
             tryForFreeLabel.text = "Only \(product.localizedPrice) a month. You spend more than that in a gumball machine!"
            
    }
        
        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            print("transactions restored")
            for transaction in queue.transactions {
                let t: SKPaymentTransaction = transaction
                let prodID = t.payment.productIdentifier as String
            
                switch prodID {
                case "budge.subscription":
                    print("Subscribe")
                    unlockApp()
                    closeIAPScreen()
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
            print(trans.error)
            
            switch trans.transactionState {
            case .purchased:
                print("Purchased! Unlock app")
                print(p.productIdentifier)
                stopSpinner()
                unlockApp()
                closeIAPScreen()
                
                let prodID = p.productIdentifier
                switch prodID {
                case "budge.subscription":
                    print("Subscribed")
                    stopSpinner()
                    unlockApp()
                    closeIAPScreen()
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
    
    
    @IBAction func alreadyASubscriberButton(_ sender: Any) {
        signOutAlert()
    }
    
    //    @IBAction func restorePurchase(_ sender: Any) {
//
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().restoreCompletedTransactions()
//        stopSpinner()
//        unlockApp()
//
//    }
    
    @IBAction func termsButton(_ sender: Any) {
        guard let url = URL(string: "https://budgeapp.wixsite.com/budge/terms-of-use") else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func privacyButton(_ sender: Any) {
        guard let url = URL(string: "https://budgeapp.wixsite.com/budge/privacy-policy") else { return }
        UIApplication.shared.open(url)
    }
    
    
    
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = .black,
             bulletColor: UIColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)) -> NSAttributedString {
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation
        
        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)
            
            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))
            
            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))
            
            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }
        
        return bulletList
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func unlockApp() {
        subscribedUser = true
        saveToFireStore()
//        defaults.set(subscribedUser, forKey: "SubscribedUser")
    }
    
    func closeIAPScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func convertDoubleToCurency(amount: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        return numberFormatter.string(from: NSNumber(value: amount))!
        
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
    
    func showRestoredAlert() {
        let alert = UIAlertController(title: "Budge Subscription Restored!", message:
        "You now have full access to the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
            self.closeIAPScreen()
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
    
    func signOutAlert() {
        let alert = UIAlertController(title: "Already a subscriber?", message: "You need to sign in with your subscriber account. First signout from Settings, then sign in with your subscriber account.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: {action in
            goToSettings = true
            self.dismiss(animated: true, completion: nil)
            
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
    
}
