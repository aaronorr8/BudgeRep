//
//  AboutViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 2/5/22.
//  Copyright © 2022 Icecream. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButtonOutlet.backgroundColor = Colors.themeBlack
        nextButtonOutlet.setTitleColor(Colors.themeWhite, for: .normal)
        nextButtonOutlet.layer.cornerRadius = nextButtonOutlet.frame.height / 2
        
//        let text = "Budge is different than other financial apps. It’s doesn’t sync with your bank. It won’t chart your spending over time. It’s intentionally simple to help you stay within your monthly budgets.".withBoldText(text: "Budge is different")
        
//        aboutLabel.attributedText = text
        
        
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Outfit-Bold", size: 23.0)!
        ]
        let regularAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Outfit-Light", size: 23.0)!
        ]
        let boldText1 = NSAttributedString(string: "Budge is different", attributes: boldAttribute)
        let boldText2 = NSAttributedString(string: "intentionally simple", attributes: boldAttribute)
        let regularText1 = NSAttributedString(string: " than other financial apps. It doesn’t sync with your bank. It won’t chart your spending over time. It’s ", attributes: regularAttribute)
        let regularText2 = NSAttributedString(string: " to help you stay within your monthly budgets.", attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText1)
        newString.append(regularText1)
        newString.append(boldText2)
        newString.append(regularText2)
        aboutLabel.attributedText = newString
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//extension String {
//func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
//    let _font = font ?? UIFont(name: "Outfit-Light", size: 23.0)
//    let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font as Any])
//    let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Outfit-Bold", size: 23.0) as Any as Any as Any]
//  let range = (self as NSString).range(of: text)
//  fullString.addAttributes(boldFontAttribute, range: range)
//  return fullString
//}}
