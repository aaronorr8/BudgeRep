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



class IAP2ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var selectedIAP = 0
    let iapTitleArray = ["1 month", "6 months", "12 months"]
    let iapPriceArray = ["$0.99", "$4.99", "$9.99"]
    let bestValueImageArray = [nil, nil, #imageLiteral(resourceName: "star")]
    let bestValueTitleArray = ["", "", "Best Value!"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //
    }
    
    
    //MARK: COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frameWidth = view.frame.width - 24

        return CGSize(width: frameWidth/3 - 10, height: 100.0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as!IAPCollectionViewCell
        
        //Set cell border
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderColor = UIColor.darkGray.cgColor
        
        
        
        cell.iapNameLabel.text = iapTitleArray[indexPath.row]
        cell.iapPriceLabel.text = iapPriceArray[indexPath.row]
        cell.bestValueImage.image = bestValueImageArray[indexPath.row]
        cell.bestValueLabel.text = bestValueTitleArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell!.layer.borderWidth = 2.0
        cell!.layer.cornerRadius = 5.0
        cell!.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)
        
        selectedIAP = indexPath.row
        showAlert()
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: "Show IAP", message: "You selected \(iapTitleArray[selectedIAP])", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
}
