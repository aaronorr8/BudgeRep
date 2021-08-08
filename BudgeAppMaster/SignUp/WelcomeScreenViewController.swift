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
    
    @IBOutlet weak var getStartedButton: UIButton!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        styleButton()
    }
    

   
    
    @IBAction func getStartedButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func LoginButton(_ sender: Any) {
        sceneLogInOnly = true
        performSegue(withIdentifier: "goToSignUp", sender: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.setAnimationsEnabled(true) //turn off animation so the welcome screen shows without sliding
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func styleButton() {
        getStartedButton.backgroundColor = #colorLiteral(red: 0, green: 0.5241034031, blue: 0.3747756481, alpha: 1)
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height/2
//        getStartedButton.layer.borderWidth = 2
//        getStartedButton.layer.borderColor = #colorLiteral(red: 0, green: 0.5241034031, blue: 0.3747756481, alpha: 1)
        getStartedButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
}
