//
//  UIApplication.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/11/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//
import UIKit

extension UIApplication {
    
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        
        if let slide = viewController as? SlideMenuController {
            return topViewController(viewController: slide.mainViewController)
        }
        return viewController
    }
}
