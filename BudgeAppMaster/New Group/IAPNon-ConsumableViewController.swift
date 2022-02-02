//
//  IAPNon-ConsumableViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/22/21.
//  Copyright © 2021 Icecream. All rights reserved.
//
//  https://www.youtube.com/watch?v=qyKmpr9EjwU

import UIKit
import StoreKit

class IAPNon_ConsumableViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    
    
    var myProduct: SKProduct?
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButtonOutlet: UIButton!
    var price = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Unlock Budge"

        
        buyButtonOutlet.backgroundColor = Colors.themeBlack
        buyButtonOutlet.setTitleColor(Colors.themeWhite, for: .normal)
        buyButtonOutlet.layer.cornerRadius = buyButtonOutlet.frame.height / 2
        
        fetchProducts()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if price == "" {
            print("price not loaded from app store")
            print("price = \(price)")
            priceLabel.text = "Create as many budgets as you want for just $2.99"
        } else {
            print("price loaded from app store")
            print("price = \(price)")
            priceLabel.text = "Create as many budgets as you want for just \(price)"
        }
    }
    

    
    
    //MARK: BUY NOW BUTTON
    @IBAction func buyButton(_ sender: Any) {
        guard let myProduct = myProduct else {
            return
        }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    
    @IBAction func restorePurchaseButton(_ sender: Any) {
        guard let myProduct = myProduct else {
            return
        }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchProducts() {
        // UnlimitedBudgets
        let request = SKProductsRequest(productIdentifiers: ["UnlimitedBudgets"])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            myProduct = product
            print(product.productIdentifier)
            print(product.price)
            print(product.localizedTitle)
            print(product.localizedDescription)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            price = String((formatter.string(from: product.price) ?? ""))
            print("price = \(price)")
            
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
            // no op
            break
            case . purchased, .restored:
            // unlock their item
                unlockApp()
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            break
            case .failed, .deferred:
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
    

  
    
    func unlockApp() {
        print("Purchase complete, unlock app")
        unlimitedUser = true
        setUserDefaults()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: Save to UserDefaults
    func setUserDefaults() {
        defaults.set(unlimitedUser, forKey: "unlimitedUser")
    }

}


