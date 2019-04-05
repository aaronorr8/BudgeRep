//
//  WelcomeViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/29/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func getStartedButton(_ sender: Any) {
        

    }
    

    @IBAction func loginButton(_ sender: Any) {
        signUpMode = false
        

    }
    


}
