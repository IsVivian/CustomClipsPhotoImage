//
//  Extension.swift
//  CustomClipsPhotoImage
//
//  Created by sherry on 16/11/28.
//  Copyright © 2016年 sherry. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {

    func hasAlpha() -> Bool {
    
        let alphaInfo = CGImageGetAlphaInfo(self.CGImage)
        
        return alphaInfo == CGImageAlphaInfo.First || alphaInfo == CGImageAlphaInfo.Last || alphaInfo == CGImageAlphaInfo.PremultipliedFirst || alphaInfo == CGImageAlphaInfo.PremultipliedLast
    
    }
    
    func croppedImageWithFrame(frame: CGRect) -> UIImage {
        var croppedImage: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, !self.hasAlpha(), self.scale)
        do {
            let context = UIGraphicsGetCurrentContext()
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y)
            self.drawAtPoint(CGPointZero)
            croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return UIImage(CGImage: croppedImage!.CGImage!, scale: UIScreen.mainScreen().scale, orientation: .Up)
    }
    
    
}
