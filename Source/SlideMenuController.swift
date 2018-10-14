//
//  SlideMenuController.swift
//
//  Created by Yuji Hato on 12/3/14.
//

import Foundation
import UIKit

@objc public protocol SlideMenuControllerDelegate {
    @objc optional func leftWillOpen()
    @objc optional func leftDidOpen()
    @objc optional func leftWillClose()
    @objc optional func leftDidClose()
    @objc optional func rightWillOpen()
    @objc optional func rightDidOpen()
    @objc optional func rightWillClose()
    @objc optional func rightDidClose()
}

public struct SlideMenuOptions {
    public static var leftViewWidth: CGFloat = 270.0
    public static var leftBezelWidth: CGFloat? = 16.0
    public static var contentViewScale: CGFloat = 0.96
    public static var contentViewOpacity: CGFloat = 0.5
    public static var contentViewDrag: Bool = false
    public static var shadowOpacity: CGFloat = 0.0
    public static var shadowRadius: CGFloat = 0.0
    public static var shadowOffset: CGSize = CGSize(width: 0,height: 0)
    public static var panFromBezel: Bool = true
    public static var animationDuration: CGFloat = 0.4
    public static var animationOptions: UIView.AnimationOptions = []
    public static var rightViewWidth: CGFloat = 270.0
    public static var rightBezelWidth: CGFloat? = 16.0
    public static var rightPanFromBezel: Bool = true
    public static var hideStatusBar: Bool = true
    public static var pointOfNoReturnWidth: CGFloat = 44.0
    public static var simultaneousGestureRecognizers: Bool = true
	public static var opacityViewBackgroundColor: UIColor = UIColor.black
    public static var panGesturesEnabled: Bool = true
    public static var tapGesturesEnabled: Bool = true
}

open class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {

    public enum SlideAction {
        case open
        case close
    }
    
    public enum TrackAction {
        case leftTapOpen
        case leftTapClose
        case leftFlickOpen
        case leftFlickClose
        case rightTapOpen
        case rightTapClose
        case rightFlickOpen
        case rightFlickClose
    }
    
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    open weak var delegate: SlideMenuControllerDelegate?
    
    open var opacityView = UIView()
    open var mainContainerView = UIView()
    open var leftContainerView = UIView()
    open var rightContainerView =  UIView()
    open var mainViewController: UIViewController?
    open var leftViewController: UIViewController?
    open var leftPanGesture: UIPanGestureRecognizer?
    open var leftTapGesture: UITapGestureRecognizer?
    open var rightViewController: UIViewController?
    open var rightPanGesture: UIPanGestureRecognizer?
    open var rightTapGesture: UITapGestureRecognizer?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    open override func awakeFromNib() {
        initView()
    }

    deinit { }
    
    open func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clear
        mainContainerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(mainContainerView, at: 0)

      var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = SlideMenuOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, at: 1)
      
      if leftViewController != nil {
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = SlideMenuOptions.leftViewWidth
        leftFrame.origin.x = leftMinOrigin()
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = UIView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clear
        leftContainerView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        view.insertSubview(leftContainerView, at: 2)
        addLeftGestures()
      }
      
      if rightViewController != nil {
        var rightFrame: CGRect = view.bounds
        rightFrame.size.width = SlideMenuOptions.rightViewWidth
        rightFrame.origin.x = rightMinOrigin()
        let rightOffset: CGFloat = 0
        rightFrame.origin.y = rightFrame.origin.y + rightOffset
        rightFrame.size.height = rightFrame.size.height - rightOffset
        rightContainerView = UIView(frame: rightFrame)
        rightContainerView.backgroundColor = UIColor.clear
        rightContainerView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        view.insertSubview(rightContainerView, at: 3)
        addRightGestures()
      }
    }
  
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        leftContainerView.isHidden = true
        rightContainerView.isHidden = true
      
        coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()
            self.closeRightNonAnimation()
            self.leftContainerView.isHidden = false
            self.rightContainerView.isHidden = false
      
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
  
    open override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //automatically called 
        //self.mainViewController?.viewWillAppear(animated)
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if let mainController = self.mainViewController{
            return mainController.supportedInterfaceOrientations
        }
        return UIInterfaceOrientationMask.all
    }
    
    open override var shouldAutorotate : Bool {
        return mainViewController?.shouldAutorotate ?? false
    }
        
    open override func viewWillLayoutSubviews() {
        // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        setUpViewController(rightContainerView, targetViewController: rightViewController)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.mainViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override func openLeft() {
        guard let _ = leftViewController else { // If leftViewController is nil, then return
            return
        }
        
        self.delegate?.leftWillOpen?()
        
        setOpenWindowLevel()
        // for call viewWillAppear of leftViewController
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        openLeftWithVelocity(0.0)
        
        track(.leftTapOpen)
    }
    
    open override func openRight() {
        guard let _ = rightViewController else { // If rightViewController is nil, then return
            return
        }
        
        self.delegate?.rightWillOpen?()
        
        setOpenWindowLevel()
        rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
        openRightWithVelocity(0.0)
        
        track(.rightTapOpen)
    }
    
    open override func closeLeft() {
        guard let _ = leftViewController else { // If leftViewController is nil, then return
            return
        }
        
        self.delegate?.leftWillClose?()
        
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLevel()
    }
    
    open override func closeRight() {
        guard let _ = rightViewController else { // If rightViewController is nil, then return
            return
        }
        
        self.delegate?.rightWillClose?()
        
        rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
        closeRightWithVelocity(0.0)
        setCloseWindowLevel()
    }
    
    
    open func addLeftGestures() {
    
        if leftViewController != nil {
            if SlideMenuOptions.panGesturesEnabled {
                if leftPanGesture == nil {
                    leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleLeftPanGesture(_:)))
                    leftPanGesture!.delegate = self
                    view.addGestureRecognizer(leftPanGesture!)
                }
            }
            
            if SlideMenuOptions.tapGesturesEnabled {
                if leftTapGesture == nil {
                    leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleLeft))
                    leftTapGesture!.delegate = self
                    view.addGestureRecognizer(leftTapGesture!)
                }
            }
        }
    }
    
    open func addRightGestures() {
        
        if rightViewController != nil {
            if SlideMenuOptions.panGesturesEnabled {
                if rightPanGesture == nil {
                    rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleRightPanGesture(_:)))
                    rightPanGesture!.delegate = self
                    view.addGestureRecognizer(rightPanGesture!)
                }
            }
            
            if SlideMenuOptions.tapGesturesEnabled {
                if rightTapGesture == nil {
                    rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleRight))
                    rightTapGesture!.delegate = self
                    view.addGestureRecognizer(rightTapGesture!)
                }
            }
        }
    }
    
    open func removeLeftGestures() {
        
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
        
        if leftTapGesture != nil {
            view.removeGestureRecognizer(leftTapGesture!)
            leftTapGesture = nil
        }
    }
    
    open func removeRightGestures() {
        
        if rightPanGesture != nil {
            view.removeGestureRecognizer(rightPanGesture!)
            rightPanGesture = nil
        }
        
        if rightTapGesture != nil {
            view.removeGestureRecognizer(rightTapGesture!)
            rightTapGesture = nil
        }
    }
    
    open func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    open func track(_ trackAction: TrackAction) {
        // function is for tracking
        // Please to override it if necessary
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
        static var lastState : UIGestureRecognizer.State = .ended
    }
    
    @objc func handleLeftPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        if isRightOpen() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizer.State.began:
                if LeftPanState.lastState != .ended &&  LeftPanState.lastState != .cancelled &&  LeftPanState.lastState != .failed {
                    return
                }
                
                if isLeftHidden() {
                    self.delegate?.leftWillOpen?()
                } else {
                    self.delegate?.leftWillClose?()
                }
                
                LeftPanState.frameAtStartOfPan = leftContainerView.frame
                LeftPanState.startPointOfPan = panGesture.location(in: view)
                LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
                LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
                
                leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
                addShadowToView(leftContainerView)
                setOpenWindowLevel()
        case UIGestureRecognizer.State.changed:
                if LeftPanState.lastState != .began && LeftPanState.lastState != .changed {
                    return
                }
                
                let translation: CGPoint = panGesture.translation(in: panGesture.view!)
                leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
                applyLeftOpacity()
                applyLeftContentViewScale()
        case UIGestureRecognizer.State.ended, UIGestureRecognizer.State.cancelled:
                if LeftPanState.lastState != .changed {
                    setCloseWindowLevel()
                    return
                }
                
                let velocity:CGPoint = panGesture.velocity(in: panGesture.view)
                let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
                
                if panInfo.action == .open {
                    if !LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(true, animated: true)
                    }
                    openLeftWithVelocity(panInfo.velocity)
                    
                    track(.leftFlickOpen)
                } else {
                    if LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(false, animated: true)
                    }
                    closeLeftWithVelocity(panInfo.velocity)
                    setCloseWindowLevel()
                    
                    track(.leftFlickClose)

                }
        case UIGestureRecognizer.State.failed, UIGestureRecognizer.State.possible:
                break
        }
        
        LeftPanState.lastState = panGesture.state
    }
    
    struct RightPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
        static var lastState : UIGestureRecognizer.State = .ended
    }
    
    @objc func handleRightPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        if isLeftOpen() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizer.State.began:
            if RightPanState.lastState != .ended &&  RightPanState.lastState != .cancelled &&  RightPanState.lastState != .failed {
                return
            }
            
            if isRightHidden() {
                self.delegate?.rightWillOpen?()
            } else {
                self.delegate?.rightWillClose?()
            }
            
            RightPanState.frameAtStartOfPan = rightContainerView.frame
            RightPanState.startPointOfPan = panGesture.location(in: view)
            RightPanState.wasOpenAtStartOfPan =  isRightOpen()
            RightPanState.wasHiddenAtStartOfPan = isRightHidden()
            
            rightViewController?.beginAppearanceTransition(RightPanState.wasHiddenAtStartOfPan, animated: true)
            
            addShadowToView(rightContainerView)
            setOpenWindowLevel()
        case UIGestureRecognizer.State.changed:
            if RightPanState.lastState != .began && RightPanState.lastState != .changed {
                return
            }
            
            let translation: CGPoint = panGesture.translation(in: panGesture.view!)
            rightContainerView.frame = applyRightTranslation(translation, toFrame: RightPanState.frameAtStartOfPan)
            applyRightOpacity()
            applyRightContentViewScale()
            
        case UIGestureRecognizer.State.ended, UIGestureRecognizer.State.cancelled:
            if RightPanState.lastState != .changed {
                setCloseWindowLevel()
                return
            }
            
            let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
            let panInfo: PanInfo = panRightResultInfoForVelocity(velocity)
            
            if panInfo.action == .open {
                if !RightPanState.wasHiddenAtStartOfPan {
                    rightViewController?.beginAppearanceTransition(true, animated: true)
                }
                openRightWithVelocity(panInfo.velocity)
                
                track(.rightFlickOpen)
            } else {
                if RightPanState.wasHiddenAtStartOfPan {
                    rightViewController?.beginAppearanceTransition(false, animated: true)
                }
                closeRightWithVelocity(panInfo.velocity)
                setCloseWindowLevel()
                
                track(.rightFlickClose)
            }
        case UIGestureRecognizer.State.failed, UIGestureRecognizer.State.possible:
            break
        }
        
        RightPanState.lastState = panGesture.state
    }
    
    open func openLeftWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame
        frame.origin.x = finalXOrigin
        
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(abs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        addShadowToView(leftContainerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: SlideMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
              
                SlideMenuOptions.contentViewDrag == true ? (strongSelf.mainContainerView.transform = CGAffineTransform(translationX: SlideMenuOptions.leftViewWidth, y: 0)) : (strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: SlideMenuOptions.contentViewScale, y: SlideMenuOptions.contentViewScale))
                
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                    strongSelf.delegate?.leftDidOpen?()
                }
        }
    }
    
    open func openRightWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = rightContainerView.frame.origin.x
    
        //	CGFloat finalXOrigin = SlideMenuOptions.rightViewOverlapWidth
        let finalXOrigin: CGFloat = view.bounds.width - rightContainerView.frame.size.width
        
        var frame = rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(abs(xOrigin - view.bounds.width) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
    
        addShadowToView(rightContainerView)
    
        UIView.animate(withDuration: duration, delay: 0.0, options: SlideMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.rightContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
            
                SlideMenuOptions.contentViewDrag == true ? (strongSelf.mainContainerView.transform = CGAffineTransform(translationX: -SlideMenuOptions.rightViewWidth, y: 0)) : (strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: SlideMenuOptions.contentViewScale, y: SlideMenuOptions.contentViewScale))
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.rightViewController?.endAppearanceTransition()
                    strongSelf.delegate?.rightDidOpen?()
                }
        }
    }
    
    open func closeLeftWithVelocity(_ velocity: CGFloat) {
        
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(abs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: SlideMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.removeShadow(strongSelf.leftContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                    strongSelf.delegate?.leftDidClose?()
                }
        }
    }
    
    
    open func closeRightWithVelocity(_ velocity: CGFloat) {
    
        let xOrigin: CGFloat = rightContainerView.frame.origin.x
        let finalXOrigin: CGFloat = view.bounds.width
    
        var frame: CGRect = rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(abs(xOrigin - view.bounds.width) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
    
        UIView.animate(withDuration: duration, delay: 0.0, options: SlideMenuOptions.animationOptions, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.rightContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.removeShadow(strongSelf.rightContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.rightViewController?.endAppearanceTransition()
                    strongSelf.delegate?.rightDidClose?()
                }
        }
    }
    
    
    open override func toggleLeft() {
        if isLeftOpen() {
            closeLeft()
            setCloseWindowLevel()
            // Tracking of close tap is put in here. Because closeMenu is due to be call even when the menu tap.
            
            track(.leftTapClose)
        } else {
            openLeft()
        }
    }
    
    open func isLeftOpen() -> Bool {
        return leftViewController != nil && leftContainerView.frame.origin.x == 0.0
    }
    
    open func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    open override func toggleRight() {
        if isRightOpen() {
            closeRight()
            setCloseWindowLevel()
            
            // Tracking of close tap is put in here. Because closeMenu is due to be call even when the menu tap.
            track(.rightTapClose)
        } else {
            openRight()
        }
    }
    
    open func isRightOpen() -> Bool {
        return rightViewController != nil && rightContainerView.frame.origin.x == view.bounds.width - rightContainerView.frame.size.width
    }
    
    open func isRightHidden() -> Bool {
        return rightContainerView.frame.origin.x >= view.bounds.width
    }
    
    open func changeMainViewController(_ mainViewController: UIViewController,  close: Bool) {
        
        removeViewController(self.mainViewController)
        self.mainViewController = mainViewController
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        if close {
            closeLeft()
            closeRight()
        }
    }
    
    open func changeLeftViewWidth(_ width: CGFloat) {
        
        SlideMenuOptions.leftViewWidth = width
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = width
        leftFrame.origin.x = leftMinOrigin()
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView.frame = leftFrame
    }
    
    open func changeRightViewWidth(_ width: CGFloat) {
        
        SlideMenuOptions.rightBezelWidth = width
        var rightFrame: CGRect = view.bounds
        rightFrame.size.width = width
        rightFrame.origin.x = rightMinOrigin()
        let rightOffset: CGFloat = 0
        rightFrame.origin.y = rightFrame.origin.y + rightOffset
        rightFrame.size.height = rightFrame.size.height - rightOffset
        rightContainerView.frame = rightFrame
    }
    
    open func changeLeftViewController(_ leftViewController: UIViewController, closeLeft:Bool) {
        
        removeViewController(self.leftViewController)
        self.leftViewController = leftViewController
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        if closeLeft {
            self.closeLeft()
        }
    }
    
    open func changeRightViewController(_ rightViewController: UIViewController, closeRight:Bool) {
        removeViewController(self.rightViewController)
        self.rightViewController = rightViewController
        setUpViewController(rightContainerView, targetViewController: rightViewController)
        if closeRight {
            self.closeRight()
        }
    }
    
    fileprivate func leftMinOrigin() -> CGFloat {
        return  -SlideMenuOptions.leftViewWidth
    }
    
    fileprivate func rightMinOrigin() -> CGFloat {
        return view.bounds.width
    }
    
    
    fileprivate func panLeftResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + SlideMenuOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .close : .open
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func panRightResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = -1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(view.bounds.width) - SlideMenuOptions.pointOfNoReturnWidth)
        let rightOrigin: CGFloat = rightContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = rightOrigin >= pointOfNoReturn ? .close : .open
        
        if velocity.x <= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x >= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func applyLeftTranslation(_ translation: CGPoint, toFrame:CGRect) -> CGRect {
        
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
    
    fileprivate func applyRightTranslation(_ translation: CGPoint, toFrame: CGRect) -> CGRect {
        
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
    
    fileprivate func getOpenedLeftRatio() -> CGFloat {
        
        let width: CGFloat = leftContainerView.frame.size.width
        let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    fileprivate func getOpenedRightRatio() -> CGFloat {
        
        let width: CGFloat = rightContainerView.frame.size.width
        let currentPosition: CGFloat = rightContainerView.frame.origin.x
        return -(currentPosition - view.bounds.width) / width
    }
    
    fileprivate func applyLeftOpacity() {
        
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedLeftRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    
    fileprivate func applyRightOpacity() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedRightRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    fileprivate func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedLeftRatio)
        let drag: CGFloat = SlideMenuOptions.leftViewWidth + leftContainerView.frame.origin.x
        
        SlideMenuOptions.contentViewDrag == true ? (mainContainerView.transform = CGAffineTransform(translationX: drag, y: 0)) : (mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale))
    }
    
    fileprivate func applyRightContentViewScale() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedRightRatio)
        let drag: CGFloat = rightContainerView.frame.origin.x - mainContainerView.frame.size.width
        
        SlideMenuOptions.contentViewDrag == true ? (mainContainerView.transform = CGAffineTransform(translationX: drag, y: 0)) : (mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale))
    }
    
    fileprivate func addShadowToView(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = SlideMenuOptions.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(SlideMenuOptions.shadowOpacity)
        targetContainerView.layer.shadowRadius = SlideMenuOptions.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).cgPath
    }
    
    fileprivate func removeShadow(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        mainContainerView.layer.opacity = 1.0
    }
    
    fileprivate func removeContentOpacity() {
        opacityView.layer.opacity = 0.0
    }
    

    fileprivate func addContentOpacity() {
        opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
    }
    
    fileprivate func disableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = false
    }
    
    fileprivate func enableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = true
    }
    
    fileprivate func setOpenWindowLevel() {
        if SlideMenuOptions.hideStatusBar {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindow.Level.statusBar + 1
                }
            })
        }
    }
    
    fileprivate func setCloseWindowLevel() {
        if SlideMenuOptions.hideStatusBar {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindow.Level.normal
                }
            })
        }
    }
    
    fileprivate func setUpViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            viewController.view.frame = targetView.bounds
            
            if (!children.contains(viewController)) {
                addChild(viewController)
                targetView.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }
        }
    }
    
    
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.view.layer.removeAllAnimations()
            _viewController.willMove(toParent: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParent()
        }
    }
    
    open func closeLeftNonAnimation(){
        setCloseWindowLevel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(leftContainerView)
        enableContentInteraction()
    }
    
    open func closeRightNonAnimation(){
        setCloseWindowLevel()
        let finalXOrigin: CGFloat = view.bounds.width
        var frame: CGRect = rightContainerView.frame
        frame.origin.x = finalXOrigin
        rightContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(rightContainerView)
        enableContentInteraction()
    }
    
    // MARK: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let point: CGPoint = touch.location(in: view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == rightPanGesture {
            return slideRightViewForGestureRecognizer(gestureRecognizer, withTouchPoint: point)
        } else if gestureRecognizer == leftTapGesture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        } else if gestureRecognizer == rightTapGesture {
            return isRightOpen() && !isPointContainedWithinRightRect(point)
        }
        
        return true
    }
    
    // returning true here helps if the main view is fullwidth with a scrollview
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return SlideMenuOptions.simultaneousGestureRecognizers
    }
    
    fileprivate func slideLeftForGestureRecognizer( _ gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || SlideMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isLeftPointContainedWithinBezelRect(_ point: CGPoint) -> Bool{
        if let bezelWidth = SlideMenuOptions.leftBezelWidth {
            var leftBezelRect: CGRect = CGRect.zero
            let tuple = view.bounds.divided(atDistance: bezelWidth, from: CGRectEdge.minXEdge)
            leftBezelRect = tuple.slice
            return leftBezelRect.contains(point)
        } else {
            return true
        }
    }
    
    fileprivate func isPointContainedWithinLeftRect(_ point: CGPoint) -> Bool {
        return leftContainerView.frame.contains(point)
    }
    
    
    
    fileprivate func slideRightViewForGestureRecognizer(_ gesture: UIGestureRecognizer, withTouchPoint point: CGPoint) -> Bool {
        return isRightOpen() || SlideMenuOptions.rightPanFromBezel && isRightPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isRightPointContainedWithinBezelRect(_ point: CGPoint) -> Bool {
        if let rightBezelWidth = SlideMenuOptions.rightBezelWidth {
            var rightBezelRect: CGRect = CGRect.zero
            let bezelWidth: CGFloat = view.bounds.width - rightBezelWidth
            let tuple = view.bounds.divided(atDistance: bezelWidth, from: CGRectEdge.minXEdge)
            rightBezelRect = tuple.remainder
            return rightBezelRect.contains(point)
        } else {
            return true
        }
    }
    
    fileprivate func isPointContainedWithinRightRect(_ point: CGPoint) -> Bool {
        return rightContainerView.frame.contains(point)
    }
    
}

extension UIViewController {

    public func slideMenuController() -> SlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideMenuController {
                return viewController as? SlideMenuController
            }
            viewController = viewController?.parent
        }
        return nil
    }
    
    public func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    public func addRightBarButtonWithImage(_ buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toggleRight))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc public func toggleLeft() {
        slideMenuController()?.toggleLeft()
    }

    @objc public func toggleRight() {
        slideMenuController()?.toggleRight()
    }
    
    @objc public func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    @objc public func openRight() {
        slideMenuController()?.openRight()    }
    
    @objc public func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    @objc public func closeRight() {
        slideMenuController()?.closeRight()
    }
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    public func addPriorityToMenuGesuture(_ targetScrollView: UIScrollView) {
        guard let slideController = slideMenuController(), let recognizers = slideController.view.gestureRecognizers else {
            return
        }
        for recognizer in recognizers where recognizer is UIPanGestureRecognizer {
            targetScrollView.panGestureRecognizer.require(toFail: recognizer)
        }
    }
}
