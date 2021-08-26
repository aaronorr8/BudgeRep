//
//  TestingViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 8/11/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {
    
    @IBOutlet weak var totalProgressBar: TotalProgressBar!
    
    
    
//    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalProgressBar.setProgressWithAnimation(duration: 1.0, value: 0.5)
  
    }

}
