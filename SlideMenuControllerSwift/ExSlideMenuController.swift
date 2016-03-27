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
                print("TrackAction: left tap open.")
            case .TapClose:
                print("TrackAction: left tap close.")
            case .FlickOpen:
                print("TrackAction: left flick open.")
            case .FlickClose:
                print("TrackAction: left flick close.")
            }
        case .Right:
            switch trackAction {
            case .TapOpen:
                print("TrackAction: right tap open.")
            case .TapClose:
                print("TrackAction: right tap close.")
            case .FlickOpen:
                print("TrackAction: right flick open.")
            case .FlickClose:
                print("TrackAction: right flick close.")
            }
        }
    }
}
