SlideMenuControllerSwift
========================

iOS Slide View based on iQON, Feedly, Google+, Ameba iPhone app.
![sample](Screenshots/SlideMenuControllerSwift.gif)

##Installation

####CocoaPods
comming soon...

####Manually
Add the `SlideMenuController.swift` file to your project. 

##Usage

###Basic Setup

In your app delegate:

```swift

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as MainViewController
    mainViewController.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
    mainViewController.addRightBarButtonWithImage(UIImage(named: "ic_notifications_black_24dp")!)    
    let leftViewController = storyboard.instantiateViewControllerWithIdentifier("LeftViewController") as LeftViewController
    let rightViewController = storyboard.instantiateViewControllerWithIdentifier("RightViewController") as RightViewController
    let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)

    var slideMenuController = SlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)

    self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
    self.window?.rootViewController = slideMenuController
    self.window?.makeKeyAndVisible()

    return true
}
```

If you want to use the custom option, please change the SlideMenuOption class.

```swift
class SlideMenuOption {
    
    var leftViewOverlapWidth: CGFloat = 60.0
    var leftBezelWidth: CGFloat = 16.0
    var contentViewScale: CGFloat = 0.96
    var contentViewOpacity: CGFloat = 0.5
    var shadowOpacity: CGFloat = 0.0
    var shadowRadius: CGFloat = 0.0
    var shadowOffset: CGSize = CGSizeMake(0,0)
    var panFromBezel: Bool = true
    var animationDuration: CGFloat = 0.4
    var rightViewOverlapWidth: CGFloat = 60.0
    var rightBezelWidth: CGFloat = 16.0
    var rightPanFromBezel: Bool = true
    
    init() {
        
    }
}
```

###You can access from UIViewController

```swift
self.slideMenuController()?
```
or
```swift
if let slideMenuController = self.slideMenuController() {
    // some code
}
```
### add navigationBarButton 
```swift
viewController.addLeftBarButtonWithImage(UIImage(named: "hoge")!)
viewController.addRightBarButtonWithImage(UIImage(named: "fuga")!)
```

### open and close
```swift
// Open
self.slideMenuController()?.openLeft()
self.slideMenuController()?.openRight()

// close
self.slideMenuController()?.closeLeft()
self.slideMenuController()?.closeRight()
```

## Requirements

Requires iOS 7.0 and ARC.


## Contributing

Forks, patches and other feedback are welcome.

## Creator

[Yuji Hato](https://github.com/dekatotoro)
[blog](http://buzzmemo.blogspot.jp/)

## License

SlideMenuControllerSwift is available under the MIT license. See the LICENSE file for more info.
