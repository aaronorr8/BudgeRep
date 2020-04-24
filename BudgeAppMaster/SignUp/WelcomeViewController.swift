//
//  WelcomeViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/29/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit
import StoreKit

var localizedPriceString = String()

class WelcomeViewController: UIViewController, SKProductsRequestDelegate {
    
    @IBOutlet weak var textWithPrice: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    
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
        //Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if price == "" {
            textWithPrice.text = "Try FREE for one week. No credit card needed. Then just $0.99/month if you like it. Zero risk."
        } else {
            textWithPrice.text = "Try FREE for one week. No credit card needed. Then just \(price)/month if you like it. Zero risk."
        }
        
    }
    
    
    @IBAction func getStartedButton(_ sender: Any) {
        

    }
    

    @IBAction func loginButton(_ sender: Any) {
        signUpMode = false
        

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
                
                
                
                //                localizedPriceString = ("\(product.localizedPrice)")
                
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
