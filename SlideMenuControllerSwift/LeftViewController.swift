//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case Main = 0
    case Swift
    case Java
    case Go
    case NonMenu
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    

    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Main", "Swift", "Java", "Go", "NonMenu"]
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!
    var javaViewController: UIViewController!
    var goViewController: UIViewController!
    var nonMenuViewController: UIViewController!
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        let swiftViewController = storyboard.instantiateViewControllerWithIdentifier("SwiftViewController") as SwiftViewController
        self.swiftViewController = UINavigationController(rootViewController: swiftViewController)
        
        let javaViewController = storyboard.instantiateViewControllerWithIdentifier("JavaViewController") as JavaViewController
        self.javaViewController = UINavigationController(rootViewController: javaViewController)
        
        let goViewController = storyboard.instantiateViewControllerWithIdentifier("GoViewController") as GoViewController
        self.goViewController = UINavigationController(rootViewController: goViewController)
        
        let nonMenuController = storyboard.instantiateViewControllerWithIdentifier("NonMenuController") as NonMenuController
        nonMenuController.delegate = self
        self.nonMenuViewController = UINavigationController(rootViewController: nonMenuController)
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: BaseTableViewCell = BaseTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BaseTableViewCell.identifier)
        cell.backgroundColor = UIColor(red: 64/255, green: 170/255, blue: 239/255, alpha: 1.0)
        cell.textLabel?.font = UIFont.italicSystemFontOfSize(18)
        cell.textLabel?.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        cell.textLabel?.text = menus[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Main:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .Swift:
            self.slideMenuController()?.changeMainViewController(self.swiftViewController, close: true)
            break
        case .Java:
            self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
            break
        case .Go:
            self.slideMenuController()?.changeMainViewController(self.goViewController, close: true)
            break
        case .NonMenu:
            self.slideMenuController()?.changeMainViewController(self.nonMenuViewController, close: true)
            break
        default:
            break
        }
    }
    
}