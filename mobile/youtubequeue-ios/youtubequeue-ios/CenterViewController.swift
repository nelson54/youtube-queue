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

    var networkManager: NSNetworkManager = NSNetworkManager()

    var delegate: CenterViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "menuTapped:")
        let castButtonItem = UIBarButtonItem(title: "Cast", style: UIBarButtonItemStyle.Plain, target: self, action: "castTapped:")

        navigationItem.leftBarButtonItem = menuButtonItem
        navigationItem.rightBarButtonItem = castButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.title = "Youtube Queue"
    }

    func castTapped(sender: AnyObject) {

    }

    func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftDrawer?()
    }

    func joinRoom(roomId: String) {

        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in

            let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let queueViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("QueueViewController") as? QueueViewController
            queueViewController!.roomId = roomId
            self.navigationController!.pushViewController(queueViewController!, animated: false)
            queueViewController?.delegate = self.navigationController?.parentViewController as! ContainerViewController!

        }
    }
}


extension CenterViewController: LeftDrawerViewControllerDelegate {

    func tappedQuickAdd() {
        //  self.tappedAddButton()
    }

    func quickConnectToDerek() {
        joinRoom("0iKjUBImIL")
        delegate?.toggleLeftDrawer?()
    }

    func tappedLeaveRoom() {
        self.navigationController!.popToRootViewControllerAnimated(false)
        delegate?.toggleLeftDrawer?()
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}



