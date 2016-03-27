//
//  ExSlideMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/11/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit

class ExSlideMenuController : SlideMenuController {

    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is MainViewController ||
            vc is SwiftViewController ||
            vc is JavaViewController ||
            vc is GoViewController {
                return true
            }
        }
        return false
    }
    
    override func track(slideMenu slideMenu: SlideMenu, trackAction: TrackAction) {
        switch slideMenu {
        case .Left:
            switch trackAction {
            case .TapOpen:
                print("Left tap open.")
            case .TapClose:
                print("Left tap close.")
            case .FlickOpen:
                print("Left flick open.")
            case .FlickClose:
                print("Left flick close.")
            }
        case .Right:
            switch trackAction {
            case .TapOpen:
                print("Right tap open.")
            case .TapClose:
                print("Right tap close.")
            case .FlickOpen:
                print("Right flick open.")
            case .FlickClose:
                print("Right flick close.")
            }
        }
    }
}
