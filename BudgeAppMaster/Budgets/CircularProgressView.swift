//
//  CircularProgressView.swift
//  Budget App
//
//  Created by Aaron Orr on 10/4/18.
//  Copyright © 2018 Icecream. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {

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
    
    var progressColor = Colors.progressBarProgressGreen {
        didSet {
           progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = Colors.budgetViewCellBackground {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
//        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.cornerRadius = 0

//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)

//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.75 * .pi), endAngle: CGFloat(0.75 * .pi), clockwise: true)
        
        let circlePath = UIBezierPath()
        circlePath.move(to: CGPoint(x: 0, y: frame.size.height/2))
        circlePath.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height/2))
        
        
        
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = frame.height //3.0
//        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = frame.height //6.0
//        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
//        progressLayer.lineCap = CAShapeLayerLineCap.round
    }

}
