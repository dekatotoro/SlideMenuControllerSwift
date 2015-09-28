//
//  SlideMenuController.swift
//
//  Created by Yuji Hato on 12/3/14.
//

import Foundation
import UIKit

public enum ContentAnimation {
  case None
  case Scale
  case Traslate
}

public struct SlideViewOptions {
  public var viewWidth: CGFloat = 270.0
  public var bezelWidth: CGFloat = 16.0
  public var panFromBezel: Bool = true
  public var openingBounceWidth: CGFloat = 44.0
  public var closingBounceWidth: CGFloat = 44.0
}

public struct SlideMenuOptions {
  public static var leftSlideViewOptions: SlideViewOptions = SlideViewOptions()
  public static var rightSlideViewOptions: SlideViewOptions = SlideViewOptions()
  
  public static var contentViewAnimation: ContentAnimation = .None
  public static var contentViewScale: CGFloat = 0.96
  public static var contentViewTranslation: CGFloat = 50
  
  public static var opacityViewBackgroundColor: UIColor = UIColor.blackColor()
  public static var contentViewOpacity: CGFloat = 0.5
  
  public static var shadowOpacity: CGFloat = 0.0
  public static var shadowRadius: CGFloat = 0.0
  public static var shadowOffset: CGSize = CGSizeMake(0,0)
  
  public static var animationDuration: CGFloat = 0.4
  public static var hideStatusBar: Bool = true
  
}

public class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {
  
  public enum SlideAction {
    case Open
    case Close
  }
  
  public enum TrackAction {
    case TapOpen
    case TapClose
    case FlickOpen
    case FlickClose
  }
  
  struct PanInfo {
    var action: SlideAction
    var shouldBounce: Bool
    var velocity: CGFloat
  }
  
  public var opacityView = UIView()
  public var mainContainerView = UIView()
  public var leftContainerView = UIView()
  public var rightContainerView =  UIView()
  public var mainViewController: UIViewController?
  public var leftViewController: UIViewController?
  public var leftPanGesture: UIPanGestureRecognizer?
  public var leftTapGetsture: UITapGestureRecognizer?
  public var rightViewController: UIViewController?
  public var rightPanGesture: UIPanGestureRecognizer?
  public var rightTapGesture: UITapGestureRecognizer?
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
    self.init()
    self.mainViewController = mainViewController
    leftViewController = leftMenuViewController
    initView()
  }
  
  public convenience init(mainViewController: UIViewController, rightMenuViewController: UIViewController) {
    self.init()
    self.mainViewController = mainViewController
    rightViewController = rightMenuViewController
    initView()
  }
  
  public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController, rightMenuViewController: UIViewController) {
    self.init()
    self.mainViewController = mainViewController
    leftViewController = leftMenuViewController
    rightViewController = rightMenuViewController
    initView()
  }
  
  deinit { }
  
  func initView() {
    mainContainerView = UIView(frame: view.bounds)
    mainContainerView.backgroundColor = UIColor.clearColor()
    mainContainerView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    view.insertSubview(mainContainerView, atIndex: 0)
    
    var opacityframe: CGRect = view.bounds
    let opacityOffset: CGFloat = 0
    opacityframe.origin.y = opacityframe.origin.y + opacityOffset
    opacityframe.size.height = opacityframe.size.height - opacityOffset
    opacityView = UIView(frame: opacityframe)
    opacityView.backgroundColor = SlideMenuOptions.opacityViewBackgroundColor
    opacityView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
    opacityView.layer.opacity = 0.0
    view.insertSubview(opacityView, atIndex: 1)
    
    var leftFrame: CGRect = view.bounds
    leftFrame.size.width = SlideMenuOptions.leftSlideViewOptions.viewWidth
    leftFrame.origin.x = leftMinOrigin()
    let leftOffset: CGFloat = 0
    leftFrame.origin.y = leftFrame.origin.y + leftOffset
    leftFrame.size.height = leftFrame.size.height - leftOffset
    leftContainerView = UIView(frame: leftFrame)
    leftContainerView.backgroundColor = UIColor.clearColor()
    leftContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    view.insertSubview(leftContainerView, atIndex: 2)
    
    var rightFrame: CGRect = view.bounds
    rightFrame.size.width = SlideMenuOptions.rightSlideViewOptions.viewWidth
    rightFrame.origin.x = rightMinOrigin()
    let rightOffset: CGFloat = 0
    rightFrame.origin.y = rightFrame.origin.y + rightOffset
    rightFrame.size.height = rightFrame.size.height - rightOffset
    rightContainerView = UIView(frame: rightFrame)
    rightContainerView.backgroundColor = UIColor.clearColor()
    rightContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    view.insertSubview(rightContainerView, atIndex: 3)
    
    addLeftGestures()
    addRightGestures()
  }
  
  @available(iOS 8.0, *)
  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    mainContainerView.transform = CGAffineTransformIdentity
    leftContainerView.hidden = true
    rightContainerView.hidden = true
    
    coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
      self.closeLeftNonAnimation()
      self.closeRightNonAnimation()
      self.leftContainerView.hidden = false
      self.rightContainerView.hidden = false
      
      if self.leftPanGesture != nil && self.leftPanGesture != nil {
        self.removeLeftGestures()
        self.addLeftGestures()
      }
      
      if self.rightPanGesture != nil && self.rightPanGesture != nil {
        self.removeRightGestures()
        self.addRightGestures()
      }
    })
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = UIRectEdge.None
  }
  
  public override func viewWillLayoutSubviews() {
    // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
    setUpViewController(mainContainerView, targetViewController: mainViewController)
    setUpViewController(leftContainerView, targetViewController: leftViewController)
    setUpViewController(rightContainerView, targetViewController: rightViewController)
  }
  
  public override func openLeft() {
    setOpenWindowLevel()
    
    //leftViewControllerのviewWillAppearを呼ぶため
    leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
    openLeftWithVelocity(0.0)
    
    track(.TapOpen)
  }
  
  public override func openRight() {
    setOpenWindowLevel()
    
    //menuViewControllerのviewWillAppearを呼ぶため
    rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
    openRightWithVelocity(0.0)
  }
  
  public override func closeLeft() {
    leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
    closeLeftWithVelocity(0.0)
    setCloseWindowLevel()
  }
  
  public override func closeRight() {
    rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
    closeRightWithVelocity(0.0)
    setCloseWindowLevel()
  }
  
  
  public func addLeftGestures() {
    
    if (leftViewController != nil) {
      if leftPanGesture == nil {
        leftPanGesture = UIPanGestureRecognizer(target: self, action: "handleLeftPanGesture:")
        leftPanGesture!.delegate = self
        view.addGestureRecognizer(leftPanGesture!)
      }
      
      if leftTapGetsture == nil {
        leftTapGetsture = UITapGestureRecognizer(target: self, action: "toggleLeft")
        leftTapGetsture!.delegate = self
        view.addGestureRecognizer(leftTapGetsture!)
      }
    }
  }
  
  public func addRightGestures() {
    
    if (rightViewController != nil) {
      if rightPanGesture == nil {
        rightPanGesture = UIPanGestureRecognizer(target: self, action: "handleRightPanGesture:")
        rightPanGesture!.delegate = self
        view.addGestureRecognizer(rightPanGesture!)
      }
      
      if rightTapGesture == nil {
        rightTapGesture = UITapGestureRecognizer(target: self, action: "toggleRight")
        rightTapGesture!.delegate = self
        view.addGestureRecognizer(rightTapGesture!)
      }
    }
  }
  
  public func removeLeftGestures() {
    
    if leftPanGesture != nil {
      view.removeGestureRecognizer(leftPanGesture!)
      leftPanGesture = nil
    }
    
    if leftTapGetsture != nil {
      view.removeGestureRecognizer(leftTapGetsture!)
      leftTapGetsture = nil
    }
  }
  
  public func removeRightGestures() {
    
    if rightPanGesture != nil {
      view.removeGestureRecognizer(rightPanGesture!)
      rightPanGesture = nil
    }
    
    if rightTapGesture != nil {
      view.removeGestureRecognizer(rightTapGesture!)
      rightTapGesture = nil
    }
  }
  
  public func isTagetViewController() -> Bool {
    // Function to determine the target ViewController
    // Please to override it if necessary
    return true
  }
  
  public func track(trackAction: TrackAction) {
    // function is for tracking
    // Please to override it if necessary
  }
  
  struct LeftPanState {
    static var frameAtStartOfPan: CGRect = CGRectZero
    static var startPointOfPan: CGPoint = CGPointZero
    static var wasOpenAtStartOfPan: Bool = false
    static var wasHiddenAtStartOfPan: Bool = false
  }
  
  func handleLeftPanGesture(panGesture: UIPanGestureRecognizer) {
    
    if !isTagetViewController() {
      return
    }
    
    if isRightOpen() {
      return
    }
    
    switch panGesture.state {
    case UIGestureRecognizerState.Began:
      
      LeftPanState.frameAtStartOfPan = leftContainerView.frame
      LeftPanState.startPointOfPan = panGesture.locationInView(view)
      LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
      LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
      
      leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
      addShadowToView(leftContainerView)
      setOpenWindowLevel()
    case UIGestureRecognizerState.Changed:
      
      let translation: CGPoint = panGesture.translationInView(panGesture.view!)
      leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
      applyLeftOpacity()
      applyLeftContentViewAnimation()
    case UIGestureRecognizerState.Ended:
      
      let velocity:CGPoint = panGesture.velocityInView(panGesture.view)
      let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
      
      if panInfo.action == .Open {
        if !LeftPanState.wasHiddenAtStartOfPan {
          leftViewController?.beginAppearanceTransition(true, animated: true)
        }
        openLeftWithVelocity(panInfo.velocity)
        track(.FlickOpen)
        
      } else {
        if LeftPanState.wasHiddenAtStartOfPan {
          leftViewController?.beginAppearanceTransition(false, animated: true)
        }
        closeLeftWithVelocity(panInfo.velocity)
        setCloseWindowLevel()
        
        track(.FlickClose)
        
      }
    default:
      break
    }
    
  }
  
  struct RightPanState {
    static var frameAtStartOfPan: CGRect = CGRectZero
    static var startPointOfPan: CGPoint = CGPointZero
    static var wasOpenAtStartOfPan: Bool = false
    static var wasHiddenAtStartOfPan: Bool = false
  }
  
  func handleRightPanGesture(panGesture: UIPanGestureRecognizer) {
    
    if !isTagetViewController() {
      return
    }
    
    if isLeftOpen() {
      return
    }
    
    switch panGesture.state {
    case UIGestureRecognizerState.Began:
      
      RightPanState.frameAtStartOfPan = rightContainerView.frame
      RightPanState.startPointOfPan = panGesture.locationInView(view)
      RightPanState.wasOpenAtStartOfPan =  isRightOpen()
      RightPanState.wasHiddenAtStartOfPan = isRightHidden()
      
      rightViewController?.beginAppearanceTransition(RightPanState.wasHiddenAtStartOfPan, animated: true)
      addShadowToView(rightContainerView)
      setOpenWindowLevel()
    case UIGestureRecognizerState.Changed:
      
      let translation: CGPoint = panGesture.translationInView(panGesture.view!)
      rightContainerView.frame = applyRightTranslation(translation, toFrame: RightPanState.frameAtStartOfPan)
      applyRightOpacity()
      applyRightContentViewAnimation()
      
    case UIGestureRecognizerState.Ended:
      
      let velocity: CGPoint = panGesture.velocityInView(panGesture.view)
      let panInfo: PanInfo = panRightResultInfoForVelocity(velocity)
      
      if panInfo.action == .Open {
        if !RightPanState.wasHiddenAtStartOfPan {
          rightViewController?.beginAppearanceTransition(true, animated: true)
        }
        openRightWithVelocity(panInfo.velocity)
      } else {
        if RightPanState.wasHiddenAtStartOfPan {
          rightViewController?.beginAppearanceTransition(false, animated: true)
        }
        closeRightWithVelocity(panInfo.velocity)
        setCloseWindowLevel()
      }
    default:
      break
    }
  }
  
  public func openLeftWithVelocity(velocity: CGFloat) {
    let xOrigin: CGFloat = leftContainerView.frame.origin.x
    let finalXOrigin: CGFloat = 0.0
    
    var frame = leftContainerView.frame
    frame.origin.x = finalXOrigin
    
    var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
    if velocity != 0.0 {
      duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
      duration = Double(fmax(0.1, fmin(1.0, duration)))
    }
    
    addShadowToView(leftContainerView)
    
    UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
      if let strongSelf = self {
        strongSelf.leftContainerView.frame = frame
        strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
        
        switch SlideMenuOptions.contentViewAnimation {
        case .Scale:
          strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(SlideMenuOptions.contentViewScale, SlideMenuOptions.contentViewScale)
        case .Traslate:
          strongSelf.mainContainerView.transform = CGAffineTransformMakeTranslation(self!.leftValidTranslation(), 0)
        default: break
        }
        
      }
      }) { [weak self](Bool) -> Void in
        if let strongSelf = self {
          strongSelf.disableContentInteraction()
          strongSelf.leftViewController?.endAppearanceTransition()
        }
    }
  }
  
  public func openRightWithVelocity(velocity: CGFloat) {
    let xOrigin: CGFloat = rightContainerView.frame.origin.x
    
    let finalXOrigin: CGFloat = CGRectGetWidth(view.bounds) - rightContainerView.frame.size.width
    
    var frame = rightContainerView.frame
    frame.origin.x = finalXOrigin
    
    var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
    if velocity != 0.0 {
      duration = Double(fabs(xOrigin - CGRectGetWidth(view.bounds)) / velocity)
      duration = Double(fmax(0.1, fmin(1.0, duration)))
    }
    
    addShadowToView(rightContainerView)
    
    UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
      if let strongSelf = self {
        strongSelf.rightContainerView.frame = frame
        strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
        
        switch SlideMenuOptions.contentViewAnimation {
        case .Scale:
          strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(SlideMenuOptions.contentViewScale, SlideMenuOptions.contentViewScale)
        case .Traslate:
          strongSelf.mainContainerView.transform = CGAffineTransformMakeTranslation(-self!.rightValidTranslation(), 0)
        default: break
        }
        
      }
      }) { [weak self](Bool) -> Void in
        if let strongSelf = self {
          strongSelf.disableContentInteraction()
          strongSelf.rightViewController?.endAppearanceTransition()
        }
    }
  }
  
  public func closeLeftWithVelocity(velocity: CGFloat) {
    
    let xOrigin: CGFloat = leftContainerView.frame.origin.x
    let finalXOrigin: CGFloat = leftMinOrigin()
    
    var frame: CGRect = leftContainerView.frame
    frame.origin.x = finalXOrigin
    
    var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
    if velocity != 0.0 {
      duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
      duration = Double(fmax(0.1, fmin(1.0, duration)))
    }
    
    UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
      if let strongSelf = self {
        strongSelf.leftContainerView.frame = frame
        strongSelf.opacityView.layer.opacity = 0.0
        strongSelf.mainContainerView.transform = CGAffineTransformIdentity
      }
      }) { [weak self](Bool) -> Void in
        if let strongSelf = self {
          strongSelf.removeShadow(strongSelf.leftContainerView)
          strongSelf.enableContentInteraction()
          strongSelf.leftViewController?.endAppearanceTransition()
        }
    }
  }
  
  
  public func closeRightWithVelocity(velocity: CGFloat) {
    
    let xOrigin: CGFloat = rightContainerView.frame.origin.x
    let finalXOrigin: CGFloat = CGRectGetWidth(view.bounds)
    
    var frame: CGRect = rightContainerView.frame
    frame.origin.x = finalXOrigin
    
    var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
    if velocity != 0.0 {
      duration = Double(fabs(xOrigin - CGRectGetWidth(view.bounds)) / velocity)
      duration = Double(fmax(0.1, fmin(1.0, duration)))
    }
    
    UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
      if let strongSelf = self {
        strongSelf.rightContainerView.frame = frame
        strongSelf.opacityView.layer.opacity = 0.0
        strongSelf.mainContainerView.transform = CGAffineTransformIdentity
      }
      }) { [weak self](Bool) -> Void in
        if let strongSelf = self {
          strongSelf.removeShadow(strongSelf.rightContainerView)
          strongSelf.enableContentInteraction()
          strongSelf.rightViewController?.endAppearanceTransition()
        }
    }
  }
  
  
  public override func toggleLeft() {
    if isLeftOpen() {
      closeLeft()
      setCloseWindowLevel()
      // closeMenuはメニュータップ時にも呼ばれるため、closeタップのトラッキングはここに入れる
      
      track(.TapClose)
    } else {
      openLeft()
    }
  }
  
  public func isLeftOpen() -> Bool {
    return leftContainerView.frame.origin.x == 0.0
  }
  
  public func isLeftHidden() -> Bool {
    return leftContainerView.frame.origin.x <= leftMinOrigin()
  }
  
  public override func toggleRight() {
    if isRightOpen() {
      closeRight()
      setCloseWindowLevel()
    } else {
      openRight()
    }
  }
  
  public func isRightOpen() -> Bool {
    return rightContainerView.frame.origin.x == CGRectGetWidth(view.bounds) - rightContainerView.frame.size.width
  }
  
  public func isRightHidden() -> Bool {
    return rightContainerView.frame.origin.x >= CGRectGetWidth(view.bounds)
  }
  
  public func changeMainViewController(mainViewController: UIViewController,  close: Bool) {
    
    removeViewController(self.mainViewController)
    self.mainViewController = mainViewController
    setUpViewController(mainContainerView, targetViewController: mainViewController)
    if (close) {
      closeLeft()
      closeRight()
    }
  }
  
  public func changeLeftViewController(leftViewController: UIViewController, closeLeft:Bool) {
    
    removeViewController(self.leftViewController)
    self.leftViewController = leftViewController
    setUpViewController(leftContainerView, targetViewController: leftViewController)
    if closeLeft {
      self.closeLeft()
    }
  }
  
  public func changeRightViewController(rightViewController: UIViewController, closeRight:Bool) {
    removeViewController(self.rightViewController)
    self.rightViewController = rightViewController
    setUpViewController(rightContainerView, targetViewController: rightViewController)
    if closeRight {
      self.closeRight()
    }
  }
  
  private func leftMinOrigin() -> CGFloat {
    return  -SlideMenuOptions.leftSlideViewOptions.viewWidth
  }
  
  private func rightMinOrigin() -> CGFloat {
    return CGRectGetWidth(view.bounds)
  }
  
  private func leftValidTranslation() -> CGFloat {
    guard let leftViewWidth = leftViewController?.view.bounds.size.width else { return 0 }
    return min(leftViewWidth, SlideMenuOptions.contentViewTranslation)
  }
  
  private func rightValidTranslation() -> CGFloat {
    guard let rightViewWidth = rightViewController?.view.bounds.size.width else { return 0 }
    return min(rightViewWidth, SlideMenuOptions.contentViewTranslation)
  }
  
  private func panLeftResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
    
    let panVelocityX = velocity.x
    let thresholdVelocity: CGFloat = 1000.0
    
    var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
    
    if panVelocityX >= thresholdVelocity { // Quick open
      panInfo.action = .Open
      panInfo.velocity = panVelocityX
      
    } else if panVelocityX <= (-1.0 * thresholdVelocity) { // Quick close
      panInfo.action = .Close
      panInfo.velocity = panVelocityX
      
    } else {
      let leftOrigin: CGFloat = leftContainerView.frame.origin.x
      let pointOfNoReturn: CGFloat
      
      if panVelocityX <= 0 { // Closing
        pointOfNoReturn = CGFloat(floor(-SlideMenuOptions.leftSlideViewOptions.closingBounceWidth))
      } else { // Opening
        pointOfNoReturn = CGFloat(floor(leftMinOrigin())) + SlideMenuOptions.leftSlideViewOptions.openingBounceWidth
      }
      
      panInfo.action = leftOrigin <= pointOfNoReturn ? .Close : .Open
      
    }
    
    
    return panInfo
  }
  
  private func panRightResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
    
    let panVelocityX = velocity.x
    let thresholdVelocity: CGFloat = -1000.0
    
    var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
    
    if panVelocityX <= thresholdVelocity {
      panInfo.action = .Open
      panInfo.velocity = panVelocityX
      
    } else if (panVelocityX >= (-1.0 * thresholdVelocity)) {
      panInfo.action = .Close
      panInfo.velocity = panVelocityX
      
    } else {
      let rightOrigin: CGFloat = rightContainerView.frame.origin.x
      let pointOfNoReturn: CGFloat
      
      if panVelocityX >= 0 { // Closing
        pointOfNoReturn = CGFloat(floor(rightMinOrigin() - CGRectGetWidth(rightContainerView.bounds)) + SlideMenuOptions.rightSlideViewOptions.closingBounceWidth)
      } else { // Opening
        pointOfNoReturn = CGFloat(floor(rightMinOrigin()) - SlideMenuOptions.rightSlideViewOptions.openingBounceWidth)
      }
      
      panInfo.action = rightOrigin >= pointOfNoReturn ? .Close : .Open
      
    }
    
    return panInfo
  }
  
  private func applyLeftTranslation(translation: CGPoint, toFrame:CGRect) -> CGRect {
    
    var newOrigin: CGFloat = toFrame.origin.x
    newOrigin += translation.x
    
    let minOrigin: CGFloat = leftMinOrigin()
    let maxOrigin: CGFloat = 0.0
    var newFrame: CGRect = toFrame
    
    if newOrigin < minOrigin {
      newOrigin = minOrigin
    } else if newOrigin > maxOrigin {
      newOrigin = maxOrigin
    }
    
    newFrame.origin.x = newOrigin
    return newFrame
  }
  
  private func applyRightTranslation(translation: CGPoint, toFrame: CGRect) -> CGRect {
    
    var  newOrigin: CGFloat = toFrame.origin.x
    newOrigin += translation.x
    
    let minOrigin: CGFloat = rightMinOrigin()
    let maxOrigin: CGFloat = rightMinOrigin() - rightContainerView.frame.size.width
    var newFrame: CGRect = toFrame
    
    if newOrigin > minOrigin {
      newOrigin = minOrigin
    } else if newOrigin < maxOrigin {
      newOrigin = maxOrigin
    }
    
    newFrame.origin.x = newOrigin
    return newFrame
  }
  
  private func getOpenedLeftRatio() -> CGFloat {
    
    let width: CGFloat = leftContainerView.frame.size.width
    let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
    return currentPosition / width
  }
  
  private func getOpenedRightRatio() -> CGFloat {
    
    let width: CGFloat = rightContainerView.frame.size.width
    let currentPosition: CGFloat = rightContainerView.frame.origin.x
    return -(currentPosition - CGRectGetWidth(view.bounds)) / width
  }
  
  private func applyLeftOpacity() {
    
    let openedLeftRatio: CGFloat = getOpenedLeftRatio()
    let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedLeftRatio
    opacityView.layer.opacity = Float(opacity)
  }
  
  
  private func applyRightOpacity() {
    let openedRightRatio: CGFloat = getOpenedRightRatio()
    let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedRightRatio
    opacityView.layer.opacity = Float(opacity)
  }
  
  private func applyLeftContentViewAnimation() {
    guard SlideMenuOptions.contentViewAnimation != ContentAnimation.None else { return }
    
    let openedLeftRatio: CGFloat = getOpenedLeftRatio()
    
    switch SlideMenuOptions.contentViewAnimation {
    case .Scale:
      let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedLeftRatio)
      mainContainerView.transform = CGAffineTransformMakeScale(scale, scale)
      
    case .Traslate:
      mainContainerView.transform = CGAffineTransformMakeTranslation(leftValidTranslation() * openedLeftRatio, 0)
      
    default: break
    }
  }
  
  private func applyRightContentViewAnimation() {
    guard SlideMenuOptions.contentViewAnimation != ContentAnimation.None else { return }
    
    let openedRightRatio: CGFloat = getOpenedRightRatio()
    
    switch SlideMenuOptions.contentViewAnimation {
    case .Scale:
      let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedRightRatio)
      mainContainerView.transform = CGAffineTransformMakeScale(scale, scale)
      
    case .Traslate:
      mainContainerView.transform = CGAffineTransformMakeTranslation(-rightValidTranslation() * openedRightRatio, 0)
      
    default: break
    }
  }
  
  private func addShadowToView(targetContainerView: UIView) {
    targetContainerView.layer.masksToBounds = false
    targetContainerView.layer.shadowOffset = SlideMenuOptions.shadowOffset
    targetContainerView.layer.shadowOpacity = Float(SlideMenuOptions.shadowOpacity)
    targetContainerView.layer.shadowRadius = SlideMenuOptions.shadowRadius
    targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).CGPath
  }
  
  private func removeShadow(targetContainerView: UIView) {
    targetContainerView.layer.masksToBounds = true
    mainContainerView.layer.opacity = 1.0
  }
  
  private func removeContentOpacity() {
    opacityView.layer.opacity = 0.0
  }
  
  
  private func addContentOpacity() {
    opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
  }
  
  private func disableContentInteraction() {
    mainContainerView.userInteractionEnabled = false
  }
  
  private func enableContentInteraction() {
    mainContainerView.userInteractionEnabled = true
  }
  
  private func setOpenWindowLevel() {
    if (SlideMenuOptions.hideStatusBar) {
      dispatch_async(dispatch_get_main_queue(), {
        if let window = UIApplication.sharedApplication().keyWindow {
          window.windowLevel = UIWindowLevelStatusBar + 1
        }
      })
    }
  }
  
  private func setCloseWindowLevel() {
    if (SlideMenuOptions.hideStatusBar) {
      dispatch_async(dispatch_get_main_queue(), {
        if let window = UIApplication.sharedApplication().keyWindow {
          window.windowLevel = UIWindowLevelNormal
        }
      })
    }
  }
  
  private func setUpViewController(targetView: UIView, targetViewController: UIViewController?) {
    if let viewController = targetViewController {
      addChildViewController(viewController)
      viewController.view.frame = targetView.bounds
      targetView.addSubview(viewController.view)
      viewController.didMoveToParentViewController(self)
    }
  }
  
  
  private func removeViewController(viewController: UIViewController?) {
    if let _viewController = viewController {
      _viewController.willMoveToParentViewController(nil)
      _viewController.view.removeFromSuperview()
      _viewController.removeFromParentViewController()
    }
  }
  
  public func closeLeftNonAnimation(){
    setCloseWindowLevel()
    let finalXOrigin: CGFloat = leftMinOrigin()
    var frame: CGRect = leftContainerView.frame
    frame.origin.x = finalXOrigin
    leftContainerView.frame = frame
    opacityView.layer.opacity = 0.0
    mainContainerView.transform = CGAffineTransformIdentity
    removeShadow(leftContainerView)
    enableContentInteraction()
  }
  
  public func closeRightNonAnimation(){
    setCloseWindowLevel()
    let finalXOrigin: CGFloat = CGRectGetWidth(view.bounds)
    var frame: CGRect = rightContainerView.frame
    frame.origin.x = finalXOrigin
    rightContainerView.frame = frame
    opacityView.layer.opacity = 0.0
    mainContainerView.transform = CGAffineTransformIdentity
    removeShadow(rightContainerView)
    enableContentInteraction()
  }
  
  //pragma mark – UIGestureRecognizerDelegate
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    
    let point: CGPoint = touch.locationInView(view)
    
    if gestureRecognizer == leftPanGesture {
      return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
    } else if gestureRecognizer == rightPanGesture {
      return slideRightViewForGestureRecognizer(gestureRecognizer, withTouchPoint: point)
    } else if gestureRecognizer == leftTapGetsture {
      return isLeftOpen() && !isPointContainedWithinLeftRect(point)
    } else if gestureRecognizer == rightTapGesture {
      return isRightOpen() && !isPointContainedWithinRightRect(point)
    }
    
    return true
  }
  
  private func slideLeftForGestureRecognizer( gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
    return isLeftOpen() || SlideMenuOptions.leftSlideViewOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
  }
  
  private func isLeftPointContainedWithinBezelRect(point: CGPoint) -> Bool{
    var leftBezelRect: CGRect = CGRectZero
    var tempRect: CGRect = CGRectZero
    let bezelWidth: CGFloat = SlideMenuOptions.leftSlideViewOptions.bezelWidth
    
    CGRectDivide(view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.MinXEdge)
    return CGRectContainsPoint(leftBezelRect, point)
  }
  
  private func isPointContainedWithinLeftRect(point: CGPoint) -> Bool {
    return CGRectContainsPoint(leftContainerView.frame, point)
  }
  
  
  
  private func slideRightViewForGestureRecognizer(gesture: UIGestureRecognizer, withTouchPoint point: CGPoint) -> Bool {
    return isRightOpen() || SlideMenuOptions.rightSlideViewOptions.panFromBezel && isRightPointContainedWithinBezelRect(point)
  }
  
  private func isRightPointContainedWithinBezelRect(point: CGPoint) -> Bool {
    var rightBezelRect: CGRect = CGRectZero
    var tempRect: CGRect = CGRectZero
    let bezelWidth: CGFloat = CGRectGetWidth(view.bounds) - SlideMenuOptions.rightSlideViewOptions.bezelWidth
    
    CGRectDivide(view.bounds, &tempRect, &rightBezelRect, bezelWidth, CGRectEdge.MinXEdge)
    
    return CGRectContainsPoint(rightBezelRect, point)
  }
  
  private func isPointContainedWithinRightRect(point: CGPoint) -> Bool {
    return CGRectContainsPoint(rightContainerView.frame, point)
  }
  
}


extension UIViewController {
  
  public func slideMenuController() -> SlideMenuController? {
    var viewController: UIViewController? = self
    while viewController != nil {
      if viewController is SlideMenuController {
        return viewController as? SlideMenuController
      }
      viewController = viewController?.parentViewController
    }
    return nil
  }
  
  public func addLeftBarButtonWithImage(buttonImage: UIImage) {
    let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "toggleLeft")
    navigationItem.leftBarButtonItem = leftButton
  }
  
  public func addRightBarButtonWithImage(buttonImage: UIImage) {
    let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "toggleRight")
    navigationItem.rightBarButtonItem = rightButton
  }
  
  public func toggleLeft() {
    slideMenuController()?.toggleLeft()
  }
  
  public func toggleRight() {
    slideMenuController()?.toggleRight()
  }
  
  public func openLeft() {
    slideMenuController()?.openLeft()
  }
  
  public func openRight() {
    slideMenuController()?.openRight()
  }
  
  public func closeLeft() {
    slideMenuController()?.closeLeft()
  }
  
  public func closeRight() {
    slideMenuController()?.closeRight()
  }
  
  // Please specify if you want menu gesuture give priority to than targetScrollView
  public func addPriorityToMenuGesuture(targetScrollView: UIScrollView) {
    guard let slideControlelr = slideMenuController(), let recognizers = slideControlelr.view.gestureRecognizers else {
      return
    }
    for recognizer in recognizers where recognizer is UIPanGestureRecognizer {
      targetScrollView.panGestureRecognizer.requireGestureRecognizerToFail(recognizer)
    }
  }
}