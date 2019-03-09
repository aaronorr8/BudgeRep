//
//  RemindersTableViewCell.swift
//  Budget App
//
//  Created by Aaron Orr on 11/16/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var linkedBudget: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        checkmarkImage.image = checkmarkImage.image?.withRenderingMode(.alwaysTemplate)
//        checkmarkImage.tintColor = bgColorGradient1
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
