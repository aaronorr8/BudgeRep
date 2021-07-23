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
    
    @IBOutlet weak var buyButtonOutlet: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Unlock Budge"

        //Add rounded outline to save button
        buyButtonOutlet.backgroundColor = .clear
        buyButtonOutlet.layer.cornerRadius = 10
        buyButtonOutlet.layer.borderWidth = 2
        buyButtonOutlet.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
        fetchProducts()
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
        
    }
    
    
    //MARK: Save to UserDefaults
    func setUserDefaults() {
        defaults.set(unlimitedUser, forKey: "unlimitedUser")
    }

}
