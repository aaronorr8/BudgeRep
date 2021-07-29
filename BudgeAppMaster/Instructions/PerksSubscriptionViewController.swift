//
//  PerksSubscriptionViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/28/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class PerksSubscriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func getStartedButton(_ sender: Any) {
        if subscribedUser == true {
            performSegue(withIdentifier: "goToSignUp", sender: self)
        } else {
            performSegue(withIdentifier: "goToSubscription", sender: self)
        }
    }
    

    @IBAction func goToLoginButton(_ sender: Any) {
        sceneLogInOnly = true
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
