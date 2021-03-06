//
//  LobbyViewController.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/11/15.
//  Copyright © 2015 michaelsimard. All rights reserved.
//

import UIKit

class LobbyViewController: CenterViewController {

    @IBOutlet weak var enterCodeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func joinRoomPressed(sender: AnyObject) {

        if (enterCodeTextField.text != "") {
            self .joinRoom(enterCodeTextField.text!)
        }
    }

    @IBAction func createRoomPressed(sender: AnyObject) {
        networkManager.createRoom {
            (roomId) -> Void in
            self.joinRoom(roomId)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LobbyViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        enterCodeTextField.resignFirstResponder()
        return true;
    }

}