//
//  TotalProgressBar.swift
//  BudgeAppMaster
//
//  Created by Aaron Orr on 8/25/21.
//  Copyright © 2021 Icecream. All rights reserved.
//

import UIKit
import SwiftUI

class TotalProgressBar: UIView {
    
    
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }

    var progressColor = UIColor.blue {
        didSet {
           progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.yellow {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 0



        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.size.height/2))
        path.addLine(to: CGPoint(x: cellWidth, y: frame.size.height/2))
//        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height/2))


        trackLayer.path = path.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = frame.height
        trackLayer.lineCap = CAShapeLayerLineCap.butt
        layer.addSublayer(trackLayer)

        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = frame.height
        progressLayer.lineCap = CAShapeLayerLineCap.butt
        layer.addSublayer(progressLayer)
    }

   
    
    func setProgressWithAnimation(duration: TimeInterval, fromValue: Float, toValue: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(toValue)
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    

    
}
