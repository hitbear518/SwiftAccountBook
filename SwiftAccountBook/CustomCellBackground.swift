//
//  CustomCellBackground.swift
//  CollectionViewLearn
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class CustomCellBackground: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        bezierPath.lineWidth = 5.0
        UIColor.blackColor().setStroke()
        
        let fillColor = UIColor(red: 0.529, green: 0.808, blue: 0.922, alpha: 1)
        fillColor.setFill()
        
        bezierPath.stroke()
        bezierPath.fill()
        
        CGContextRestoreGState(aRef)
    }
}
