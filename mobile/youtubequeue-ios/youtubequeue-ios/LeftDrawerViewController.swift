//
//  LeftDrawerViewController.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/9/15.
//  Copyright © 2015 michaelsimard. All rights reserved.
//

import UIKit

@objc
protocol LeftDrawerViewControllerDelegate {
    optional func tappedQuickAdd()
     optional func quickConnectToDerek()
    optional func tappedLeaveRoom()

    //  optional func closeLeftDrawer()
}


class LeftDrawerViewController: UIViewController {

    var delegate: LeftDrawerViewControllerDelegate?
    let settingOptions:Array<String> = ["Quick Add", "Browse Youtube","Show Queue","Leave Room","Invite Friends","Rate Us","Derek"]
    
    @IBOutlet weak var tableView: UITableView!

    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView .registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


// MARK: UITableViewDelegate
extension LeftDrawerViewController :UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.row){
        case 0:
            print (0)
            delegate?.tappedQuickAdd?()
        case 1:
            print(1)
        case 2:
            print(2)
        case 3:
            delegate?.tappedLeaveRoom?()
            print(3)
        case 4:
            print(4)
        case 5:
            print (5)
        case 6:
            print (6)
            delegate?.quickConnectToDerek?()
        default:
            print ("Default")
        }
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 100
    //    }
    
}

// MARK: UITableViewDatasource

extension LeftDrawerViewController :UITableViewDataSource{
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")!
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                cell.textLabel?.text = self.settingOptions[indexPath.row]
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.contentView.backgroundColor = UIColor.darkGrayColor()
                cell.textLabel?.backgroundColor=UIColor.darkGrayColor()
                cell.setNeedsLayout()
            }
    
            return cell
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            
            return settingOptions.count
    }
}
