//
//  CenterViewController.swift
//  
//
//  Created by Michael on 12/11/15.
//
//

import UIKit


@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftDrawer()
    //  optional func closeLeftDrawer()
}

class CenterViewController: UIViewController {
    var delegate: CenterViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuButtonItem = UIBarButtonItem(title:"Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "menuTapped:")
        let castButtonItem = UIBarButtonItem(title:"Cast", style: UIBarButtonItemStyle.Plain, target: self, action: "")

        navigationItem.leftBarButtonItem = menuButtonItem
        navigationItem.rightBarButtonItem = castButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.title = "Youtube Queue"
    }
    
     func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftDrawer?()
    }
}

extension CenterViewController:LeftDrawerViewControllerDelegate {
    
    func tappedQuickAdd(){
      //  self.tappedAddButton()
    }
    
    func quickConnectToDerek() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let queueViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("QueueViewController") as? QueueViewController
        queueViewController!.roomId = "0iKjUBImIL"
        
        self.navigationController!.pushViewController(queueViewController!, animated: false)
        queueViewController?.delegate = navigationController?.parentViewController as! ContainerViewController!
        delegate?.toggleLeftDrawer?()
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func tappedLeaveRoom() {
        self.navigationController!.popToRootViewControllerAnimated(false)
        delegate?.toggleLeftDrawer?()
        navigationItem.rightBarButtonItem?.enabled = false

    }
}



