//
//  AddSpendNavigationController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 9/7/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class AddSpendNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let amountSpent = budgetHistoryAmountG[budgetNameG[myIndexG]]?.reduce(0, +) ?? 0.0
        let budgetedAmount = budgetAmountG[myIndexG]
        let percentSpent = amountSpent/budgetedAmount
        
        var backgroundColor = Colors.themeGray
        switch percentSpent {
        case 1.0:
            backgroundColor = Colors.themeBlue
        case _ where percentSpent > 1.0:
            backgroundColor = Colors.themeRed
        case _ where percentSpent < 0.95:
            backgroundColor = Colors.themeGreen
        case _ where percentSpent >= 0.95 && percentSpent < 1.0:
            backgroundColor = Colors.themeYellow
        default:
            backgroundColor = Colors.themeBlue
        }

        appearance.backgroundColor = backgroundColor
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        
        navigationBar.tintColor = .black
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
