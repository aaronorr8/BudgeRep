//
//  SyncInstructionsViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/28/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class SyncInstructionsViewController: UIViewController {
    
    @IBOutlet weak var bulletPoint1: UILabel!
    @IBOutlet weak var bulletPoint2: UILabel!
    @IBOutlet weak var sendLinkButtonOutlet: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bulletPoint1.layer.cornerRadius = bulletPoint1.frame.height/2
        bulletPoint1.layer.masksToBounds = true
        bulletPoint1.backgroundColor = Colors.themeAccentGreen
        
        bulletPoint2.layer.cornerRadius = bulletPoint2.frame.height/2
        bulletPoint2.layer.masksToBounds = true
        bulletPoint2.backgroundColor = Colors.themeAccentGreen
        
        sendLinkButtonOutlet.layer.cornerRadius = sendLinkButtonOutlet.frame.height/2
        sendLinkButtonOutlet.backgroundColor = Colors.budgetViewCellBackground

        self.title = ""
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        if emailG == "" {
            emailLabel.isHidden = true
        } else {
            emailLabel.text = emailG
        }
    }
    
    @IBAction func sendLinkButton(_ sender: Any) {
        
        let vc = UIActivityViewController(activityItems: ["Install the Budge app to sync between devices. https://apps.apple.com/us/app/budge-budgets-and-spending/id1459906400"], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
                
        self.present(vc, animated: true, completion: nil)
    }
    
    

    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
