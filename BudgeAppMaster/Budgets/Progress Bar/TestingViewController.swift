//
//  TestingViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 8/11/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        circularProgressView.setProgressWithAnimation(duration: 0.75, value: 1.0)
        
        
    }
    

}
