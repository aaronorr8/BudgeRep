//
//  AddBudgetNavigationController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 9/10/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class AddBudgetNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = Colors.progressBarProgressBlue
        navigationBar.standardAppearance = appearance;
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
