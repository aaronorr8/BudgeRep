//
//  BudgetCollectionViewCell.swift
//  Budget App
//
//  Created by Aaron Orr on 8/13/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit

class BudgetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var budgetNameLabel: UILabel!
    @IBOutlet weak var budgetRemainingLabel: UILabel!
    @IBOutlet weak var progressTotalLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
//    @IBOutlet weak var progressBar: SimpleProgressView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressContainer: UIView!
    
    
    
}
