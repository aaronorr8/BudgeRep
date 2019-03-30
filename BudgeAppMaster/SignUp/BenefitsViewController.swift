//
//  BenefitsViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 3/29/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import UIKit

class BenefitsViewController: UIViewController {
    
    @IBOutlet weak var benefitList: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
//        let label = UILabel()
//        label.frame = CGRect(x: 40, y: 100, width: 280, height: 600)
//        label.textColor = UIColor.lightGray
//        label.numberOfLines = 0
        
        let arrayString = [
            "Easily create your own budgets and track spending.",
            "Sync your budget with everyone in your household.",
            "Set reminders so you never miss a bill's due date."
        ]
        
        benefitList.attributedText = add(stringList: arrayString, font: benefitList.font, bullet: "\u{2022}")
        
        self.view.addSubview(benefitList)
    }
    

    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = .gray,
             bulletColor: UIColor = #colorLiteral(red: 0.2549019608, green: 0.4588235294, blue: 0.01960784314, alpha: 1)) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }


}
