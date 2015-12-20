//
//  ContainerViewController.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/9/15.
//  Copyright © 2015 michaelsimard. All rights reserved.
//

import UIKit

enum SlideOutState {
    case LeftDrawerClosed
    case LeftDrawerOpened
}


class ContainerViewController: UIViewController {

    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    var currentState: SlideOutState = .LeftDrawerClosed {
        didSet {
            let shouldShowShadow = currentState != .LeftDrawerClosed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }

    var leftViewController: LeftDrawerViewController?

    let centerPanelExpandedOffset: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()

        centerViewController = UIStoryboard.lobbyViewController()
        centerViewController.delegate = self

        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)

        centerNavigationController.didMoveToParentViewController(self)
        centerNavigationController.navigationBar.tintColor = UIColor .redColor()
        centerNavigationController.navigationBar.barTintColor = UIColor.blackColor()
        centerNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]




        //    centerNavigationController.navigationBar.barStyle = UIBarStyle.


//        var refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "buttonMethod") //Use a selector
//        centerNavigationController.navigationItem.leftBarButtonItem = refreshButton
//        


        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ContainerViewController: CenterViewControllerDelegate {

    func toggleLeftDrawer() {
        let notAlreadyExpanded = (currentState != .LeftDrawerOpened)

        if notAlreadyExpanded {
            addLeftDrawerViewController()
        }

        animateLeftDrawer(shouldExpand: notAlreadyExpanded)
    }


    func closeLeftDrawer() {
        switch (currentState) {
        case .LeftDrawerOpened:
            toggleLeftDrawer()
        default:
            break
        }
    }

    func addLeftDrawerViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            addChildSidePanelController(leftViewController!)
        }
    }

    func addChildSidePanelController(leftDrawViewController: LeftDrawerViewController) {
        print(centerNavigationController?.viewControllers.count)
        leftDrawViewController.delegate = centerNavigationController?.viewControllers.last as! CenterViewController!
        view.insertSubview(leftDrawViewController.view, atIndex: 0)
        addChildViewController(leftDrawViewController)
        leftDrawViewController.didMoveToParentViewController(self)
    }


    func animateLeftDrawer(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftDrawerOpened

            animateCenterPanelXPosition(targetPosition: 150)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) {
                finished in
                self.currentState = .LeftDrawerClosed

                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }

    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }

    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }

}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)

        switch (recognizer.state) {
        case .Began:
            if (currentState == .LeftDrawerClosed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftDrawerViewController()
                }
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if (currentState == .LeftDrawerClosed && recognizer.translationInView(view).x > 0) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            } else if (currentState == .LeftDrawerOpened) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)

            }

        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftDrawer(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }

    class func leftViewController() -> LeftDrawerViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftDrawerViewController") as? LeftDrawerViewController
    }

    class func queueViewController() -> QueueViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("QueueViewController") as? QueueViewController
    }

    class func lobbyViewController() -> LobbyViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LobbyViewController") as? LobbyViewController
    }


}


