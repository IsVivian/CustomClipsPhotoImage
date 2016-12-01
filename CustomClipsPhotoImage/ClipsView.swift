//
//  ClipsView.swift
//  CustomClipsPhotoImage
//
//  Created by sherry on 16/11/25.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit

class ClipsView: UIView {

    var shapePath: UIBezierPath!
    var shapePaths: [UIBezierPath]!
    var coverColor: UIColor!
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context!, rect)
        
        let clipPath = UIBezierPath(rect: self.bounds)
        
        clipPath.appendPath(self.shapePath)
        
        if self.shapePaths != nil {
            for path in self.shapePaths {
                
                clipPath.appendPath(path)
                
            }
        }
        
        clipPath.usesEvenOddFillRule = true
        clipPath.addClip()
        
        if self.coverColor == nil {
            self.coverColor = UIColor.blackColor()
            CGContextSetAlpha(context!, 0.7)
        }
        
        self.coverColor.setFill()
        clipPath.fill()
        
    }
    
}
