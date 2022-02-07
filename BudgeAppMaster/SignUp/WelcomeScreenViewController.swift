//
//  WelcomeScreenViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/25/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController {
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var viewOutlet: UIView!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        styleButton()
    }
    

   
    
    @IBAction func getStartedButton(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func LoginButton(_ sender: Any) {
        isWelcomeScreenLogin = true
        signUpMode = false
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
        getStartedButton.backgroundColor = Colors.themeBlack
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height/2
        getStartedButton.setTitleColor(.white, for: .normal)
        
        loginButtonOutlet.backgroundColor = Colors.themeGray
        loginButtonOutlet.layer.cornerRadius = loginButtonOutlet.frame.height/2
        loginButtonOutlet.setTitleColor(Colors.themeBlack, for: .normal)
        
        viewOutlet.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        viewOutlet.layer.cornerRadius = 15
    }
}
