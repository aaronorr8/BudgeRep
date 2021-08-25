//
//  TestingViewController.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 8/11/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {
  
    @IBOutlet weak var totalProgressBarView: TotalProgressBar!
    
    
//    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalProgressBarView.setProgressWithAnimation(duration: 1.0, value: 0.5)
        
        
       
        
//        let center = view.center
//
//        //Create track layer
//        let trackLayer = CAShapeLayer()
//        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
//        trackLayer.path = circularPath.cgPath
//
//        trackLayer.strokeColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
//        trackLayer.lineWidth = 100
//        trackLayer.fillColor = UIColor.clear.cgColor
//        trackLayer.lineCap = CAShapeLayerLineCap.round
//        view.layer.addSublayer(trackLayer)
//
//        //Create progress layer
//        shapeLayer.path = circularPath.cgPath
//
//        shapeLayer.strokeColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
//        shapeLayer.lineWidth = 100
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineCap = CAShapeLayerLineCap.round
//
//        shapeLayer.strokeEnd = 0
//
//        view.layer.addSublayer(shapeLayer)
//
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
   
        
        
        
    }
    
//    @objc private func handleTap() {
//        print("Attempting to animate stroke")
//
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//
//        basicAnimation.toValue = 1
//
//        basicAnimation.duration = 2
//
//        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//        basicAnimation.isRemovedOnCompletion = false
//
//        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
//    }
    

}
