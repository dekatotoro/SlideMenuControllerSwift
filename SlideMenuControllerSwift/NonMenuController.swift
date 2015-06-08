//
//  NonMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/22/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit



class NonMenuController: UIViewController {
    
    weak var delegate: LeftMenuProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNavigationBarItem()
    }
  
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if let viewController = self.slideMenuController()?.mainViewController as? UINavigationController {
                if viewController.topViewController.isKindOfClass(NonMenuController) {
                    self.slideMenuController()?.removeLeftGestures()
                    self.slideMenuController()?.removeRightGestures()
                }
            }
        })
    }
  
    @IBAction func didTouchToMain(sender: UIButton) {
        delegate?.changeViewController(LeftMenu.Main)
    }
}
