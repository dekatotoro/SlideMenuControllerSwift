//
//  StringExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/22/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import Foundation

extension String {
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).componentsSeparatedBy(".").last!
    }
    
    func substring(from: Int) -> String {
        return self.substringFrom(self.startIndex.advancedBy(from))
    }
    
    var length: Int {
        return self.characters.count
    }
}
