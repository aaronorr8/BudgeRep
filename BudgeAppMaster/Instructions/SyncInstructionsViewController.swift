//
//  SyncInstructionsViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 7/28/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class SyncInstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "How to Sync"
    }
    

    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
