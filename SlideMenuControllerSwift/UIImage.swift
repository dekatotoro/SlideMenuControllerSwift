//
//  UIIMage.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/5/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit

extension UIImage {
    func trim(trimRect trimRect :CGRect) -> UIImage {
//        if CGRect(origin: CGPoint.zero, size: self.size).contains(trimRect) {
//            if let imageRef = CGImageCreateWithImageInRect(self.cgImage ?? <#default value#>, trimRect) {
//                return UIImage(cgImage: imageRef)
//            }
//        }
//
//        if CGRect(origin: CGPoint.zero, size: self.size).contains(trimRect) {
//            if let imageRef = CGImage.cropping(self.cgImage ?? <#default value#>){
//                return UIImage(cgImage: imageRef)
//            }
//        }
        
        UIGraphicsBeginImageContextWithOptions(trimRect.size, true, self.scale)
        self.draw(in: CGRect(x: -trimRect.minX, y: -trimRect.minY, width: self.size.width, height: self.size.height))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = trimmedImage else { return self }
        
        return image
    }
}
