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
    

    @IBAction func goToLoginButton(_ sender: Any) {
        sceneLogInOnly = true
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    

}
