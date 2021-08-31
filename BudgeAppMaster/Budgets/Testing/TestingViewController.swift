//
//  TestingViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 8/11/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressContainer: UIView!
    
    
    
    //    private let progressView: UIProgressView = {
//        let progressView = UIProgressView(progressViewStyle: .bar)
//        progressView.trackTintColor = UIColor.gray
//        progressView.progressTintColor = UIColor.red
//        return progressView
//    }()
    
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(progressView)
//        progressView.frame = CGRect(x: 10, y: 100, width: view.frame.size.width-20, height: 20)
//        progressView.setProgress(0.5, animated: false)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: progressContainer.frame.size.height/2)
        progressView.trackTintColor = .gray
        
        
  
    }
    
    
    @IBAction func goButton(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.progressView.setProgress(0.75, animated: true)
        }
    }
    
}
