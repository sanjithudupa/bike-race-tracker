//
//  MapMarker.swift
//  BikeTracker
//
//  Created by Sanjith Udupa on 8/3/20.
//  Copyright © 2020 Sanjith Udupa. All rights reserved.
//

import Foundation
import UIKit

final class MapMarkerUI: UIView {
    var height:CGFloat = 30.0
    var width:CGFloat = 30.0
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        
        let botttomCircle = UIView(frame: CGRect(x: frame.width/4, y: frame.height/4, width: width, height: height))
        
        botttomCircle.layer.cornerRadius = height/2
        
        // border radius

        // border
        botttomCircle.layer.borderColor = color.cgColor
        botttomCircle.layer.backgroundColor = color.cgColor
        botttomCircle.layer.borderWidth = 1.5

        // drop shadow
        botttomCircle.layer.shadowColor = UIColor.black.cgColor
        botttomCircle.layer.shadowOpacity = 0.8
        botttomCircle.layer.shadowRadius = 3.5
        botttomCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addSubview(botttomCircle)
        
        let topCircle = UIView(frame: CGRect(x: frame.width/4 + 5, y: frame.height/4 + 5, width: width/1.5, height: height/1.5))
        
        topCircle.layer.cornerRadius = height/3
        
        topCircle.layer.borderColor = UIColor.white.cgColor
        topCircle.layer.backgroundColor = UIColor.white.cgColor
        topCircle.layer.borderWidth = 1.5

        // drop shadow
        topCircle.layer.shadowColor = UIColor.black.cgColor
        topCircle.layer.shadowOpacity = 0.8
        topCircle.layer.shadowRadius = 4
        topCircle.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addSubview(topCircle)
        
        
    }
    
    func makeCircleWithShadow(radius: CGFloat, shadowOff: CGFloat, color: UIColor){
        let shadowPath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: frame.midY), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = shadowPath.cgPath

        shadowLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: frame.midY), radius: radius - shadowOff, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath

        circleLayer.fillColor = color.cgColor
        
//        layer.addSublayer(shadowLayer)
        layer.addSublayer(circleLayer)
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension UIColor {
    //
    static let seedColors:[Int: UIColor] = [0:UIColor.systemGreen, 1:UIColor.systemRed, 2:UIColor.systemBlue, 3:UIColor.systemOrange, 4:UIColor.systemPink, 5:UIColor.systemPurple, 6:UIColor.systemYellow, 7:UIColor.systemTeal, 8:UIColor.black, 9:UIColor.systemGray]

    public static func randomColorFromSeed(input: Int) -> UIColor {
        
        if(input <= 9){
            return seedColors[input] ?? UIColor.green
        }
        
        var total: Int = 0
        let seed = String(input + 1)
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIView {

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}



