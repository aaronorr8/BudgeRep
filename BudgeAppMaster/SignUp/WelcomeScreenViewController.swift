//
//  WelcomeScreenViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/25/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

var sceneLogInOnly = false

class WelcomeScreenViewController: UIViewController {
    
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getStartedButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func LoginButton(_ sender: Any) {
        sceneLogInOnly = true
        performSegue(withIdentifier: "goToSignIn", sender: self)
        
    }
}
