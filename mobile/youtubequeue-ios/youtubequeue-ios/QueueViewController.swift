//
//  ViewController.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/4/15.
//  Copyright (c) 2015 michaelsimard. All rights reserved.
//
//6487E7C1

import UIKit
import SwiftSpinner



class QueueViewController: CenterViewController, GCKDeviceScannerListener, GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate, UITableViewDelegate, UITableViewDataSource, VideoCellDelegate {
    

    @IBOutlet weak var castButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private let kCancelTitle = "Cancel"
    private let kDisconnectTitle = "Disconnect"
    private var applicationMetadata: GCKApplicationMetadata?
    private var selectedDevice: GCKDevice?
    private var deviceManager: GCKDeviceManager?
    private var mediaInformation: GCKMediaInformation?
    private var mediaControlChannel: GCKMediaControlChannel?
    private var deviceScanner: GCKDeviceScanner
    private var networkManager: NSNetworkManager
    private var youTubeVideoList: Array<Video>
    private var currentVideo:Video?
    var roomId:String?
    
    private lazy var kReceiverAppID: String = {
        // You can add your own app id here that you get by registering with the
        // Google Cast SDK Developer Console https://cast.google.com/publish
        return kGCKMediaDefaultReceiverApplicationID
    }()
    
    
    required init(coder aDecoder: NSCoder) {
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID:
            kGCKMediaDefaultReceiverApplicationID)
        deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)
        networkManager = NSNetworkManager()
        youTubeVideoList = Array()
        super.init(coder: aDecoder)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        deviceScanner.addListener(self)
        deviceScanner.startScan()
        deviceScanner.passiveScan = true
        
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        var refreshControl: UIRefreshControl = UIRefreshControl();
        refreshControl .addTarget(self, action: Selector("refreshFromScroll:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView .addSubview(refreshControl)
        self.tableView .sendSubviewToBack(refreshControl);
        self .refreshListData { (success) -> Void in
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnCastTapped(sender: AnyObject) {
        
        deviceScanner.passiveScan = false
        if (selectedDevice == nil) {
            let alertController: UIAlertController = UIAlertController(title: "Connect to Device", message: "Connect to a device", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            
            for device in deviceScanner.devices {
                
                let defaultAction = UIAlertAction(title: device.friendlyName, style: .Default, handler: {
                    (action: UIAlertAction!) in
                    // self.title = String("HELLO")
                    self.selectedDevice = device as! GCKDevice;
                    self.connectToDevice()
                })
                alertController.addAction(defaultAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
                (action: UIAlertAction!) in
                alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            })
            
            alertController .addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil);
        }
        else {
            let identifier = NSBundle.mainBundle().bundleIdentifier
            deviceManager = GCKDeviceManager(device: selectedDevice, clientPackageName: identifier)
            selectedDevice = nil;
            deviceManager!.disconnect()
        }
    }
    
    override func tappedQuickAdd(){
        self.tappedAddButton()
    }
    
    func cast(video:Video) {
        print("Cast Video")
        
        // Show alert if not connected.
        if (deviceManager?.connectionState != GCKConnectionState.Connected) {
                let alert = UIAlertController(title: "Not Connected",
                    message: "Please connect to Cast device",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            return
        }
  
        let metadata = GCKMediaMetadata()
        metadata.setString(video.title, forKey: kGCKMetadataKeyTitle)
        metadata.addImage(GCKImage(URL: NSURL(string: video.image), width: 480, height: 360))

        
        if let url = video.videoUrl {
         
            let mediaInformation = GCKMediaInformation(
                contentID:url,
                streamType: GCKMediaStreamType.None,
                contentType: "video/mp4",
                metadata: metadata,
                streamDuration: 0,
                mediaTracks: [],
                textTrackStyle: nil,
                customData: nil
            )
            
            if let myMediaControlChannel = mediaControlChannel {
                myMediaControlChannel.loadMedia(mediaInformation, autoplay: true)
            }
        }
        
     
    }
    
    
    func connectToDevice() {
        if (selectedDevice == nil) {
            return
        }
        let identifier = NSBundle.mainBundle().bundleIdentifier
        deviceManager = GCKDeviceManager(device: selectedDevice, clientPackageName: identifier)
        deviceManager!.delegate = self
        deviceManager!.connect()
    }
    
    
    func showError(error: NSError) {
        let alert = UIAlertController(title: "Error",
            message: error.description,
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deviceDisconnected() {
        selectedDevice = nil
        deviceManager = nil
    }
    
    
    
    func refreshFromScroll(refreshControl: UIRefreshControl) {
        networkManager .getQueue(roomId!) {
            (videoList: Array<Video>) in
            self.youTubeVideoList = videoList;
            self.updateQueueTable()
            [refreshControl.endRefreshing()];
        };
    }
    
    func refreshListData(completionHandler: (success:Bool) -> Void){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SwiftSpinner.show("Getting queue")
        }
        networkManager .getQueue(roomId!) {
            (videoList: Array<Video>) in
            self.youTubeVideoList = videoList;
            print ("video list updated")
            self.updateQueueTable()
            completionHandler(success: true);

            
        };
    }
    
    func updateQueueTable() {
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
            SwiftSpinner.hide()
        }
        self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }
    
    
    @IBAction func tappedAddButton() {
        
        let alertController:UIAlertController = UIAlertController(title: "URL", message: "enter youtube url", preferredStyle: UIAlertControllerStyle.Alert)
        
        let addURLAction = UIAlertAction(title: "add", style: .Default) { (_) in
            let urlTextField = alertController.textFields![0] as UITextField
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.networkManager .addYoutubeLink(urlTextField.text!, roomId: self.roomId!, completionHandler: { (success) -> Void in
                    self .refreshListData({ (success) -> Void in
                        
                    })
                })
            })
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "URL"
        }
        
        alertController.addAction(addURLAction)
        self.presentViewController(alertController, animated: true) { () -> Void in
        }
    }
    
    func playNextVideo(){
        if youTubeVideoList.count>0 {
        currentVideo = youTubeVideoList[0]
        if let video = currentVideo{
            print ("playNextVideo " + video.title)
            self.cast(video)
        }
    }
    }
    
    func videoFinishedPlaying(){
        
        if let video = currentVideo{
            networkManager.remove(video.id, roomId: roomId!, completionHandler: { (success) -> Void in
                self .refreshListData({ (success) -> Void in
                    self .playNextVideo()
                })
            })
            
        }
    }
    
    
  
    
    @IBAction func addRandomVideos(sender: AnyObject) {
        
        self.networkManager .addYoutubeLink("https://www.youtube.com/watch?v=UUlLGnTAHeM", roomId: roomId!, completionHandler: { (success) -> Void in
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.networkManager .addYoutubeLink("https://www.youtube.com/watch?v=3LUw41dk4JY", roomId: self.roomId!, completionHandler: { (success) -> Void in
                    self.refreshListData({ (success) -> Void in
                        
                    })
                    
                })

            
            })
        
        })

        
    }
    
}


// MARK: GCKDeiceScannerListener

extension QueueViewController {
    
    func deviceDidComeOnline(device: GCKDevice!) {
        print("Device found: \(device.friendlyName)")
    }
    func deviceDidGoOffline(device: GCKDevice!) {
        print("Device went away: \(device.friendlyName)")
    }
}


// MARK: UITableViewDelegate
extension QueueViewController {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedVideo = youTubeVideoList[indexPath.row] as Video
        self.currentVideo = selectedVideo
        self .cast(selectedVideo)
        
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 100
    //    }
    
}

// MARK: UITableViewDatasource

extension QueueViewController {
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: VideoCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as! VideoCell
            
            
            let video = self.youTubeVideoList[indexPath.row]
            
            dispatch_async(dispatch_get_main_queue()) {
                () -> Void in
                
                cell.delegate = self
                cell.title.text = video.title
                cell.votesLabel.text = String(video.votes)
                //cell.thumbnailImageView = UIImageView(image: UIImage(named: video.image))
                cell.video = video;
                
                let data:NSData = NSData(contentsOfURL: NSURL(string: "http:" + video.image)!)!
                cell.thumbnailImageView.image = UIImage(data: data)
                
                cell.setNeedsLayout()
            }
            
            print(self.youTubeVideoList[indexPath.row].title)
            
            return cell
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            
            return self.youTubeVideoList.count
    }
}

// MARK: VideoCellDelegate

extension QueueViewController {
    func downVoteButtonPressed(video:Video) {
        self.networkManager .downvote(video.id, roomId: roomId!) { (success) -> Void in
            self .refreshListData({ (success) -> Void in
            })
        }
        
    }
    
    func upVoteButtonPressed(video:Video) {
        self.networkManager .upvote(video.id, roomId: roomId!) { (success) -> Void in
            self .refreshListData({ (success) -> Void in
            })
        }
    }
    
}



// [START media-control-channel]
//MARK: GCKMediaControlChannelDelegate
// [START_EXCLUDE silent]
extension QueueViewController{
    
    func mediaControlChannelDidUpdateStatus(mediaControlChannel: GCKMediaControlChannel!) {
        
        if let mediaControlChannelMediastatus = mediaControlChannel.mediaStatus{
            switch (mediaControlChannelMediastatus.playerState){
            case GCKMediaPlayerState.Buffering:
                print ("player state: buffering")
            case GCKMediaPlayerState.Unknown:
                print ("player state: unknown")
            case GCKMediaPlayerState.Playing:
                print ("player state: playing")
                
            case GCKMediaPlayerState.Idle:
                print ("player state: idle")
                
                switch (mediaControlChannelMediastatus.idleReason){
                case GCKMediaPlayerIdleReason.None:
                    print ("idle reason none")
                case GCKMediaPlayerIdleReason.Finished:
                    print ("idle reason finished")
                    videoFinishedPlaying()
                case GCKMediaPlayerIdleReason.Cancelled:
                    print ("idle reason cancelled")
                case GCKMediaPlayerIdleReason.Interrupted:
                    print ("idle reason interuppted")
                case GCKMediaPlayerIdleReason.Error:
                    print ("idle reason error")
                }
            case GCKMediaPlayerState.Paused:
                print ("player state: paused")
            }
        }
        else {
            
        }
    }
}



// [START media-control-channel]
// MARK: GCKDeviceManagerDelegate
// [START_EXCLUDE silent]

extension QueueViewController {
    
    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        print("Connected.")
        
        //  updateButtonStates()
        deviceManager.launchApplication(kReceiverAppID)
    }
    // [END_EXCLUDE]
    func deviceManager(deviceManager: GCKDeviceManager!,
        didConnectToCastApplication
        applicationMetadata: GCKApplicationMetadata!,
        sessionID: String!,
        launchedApplication: Bool) {
            print("Application has launched.")
            self.mediaControlChannel = GCKMediaControlChannel()
            mediaControlChannel!.delegate = self
            deviceManager.addChannel(mediaControlChannel)
            mediaControlChannel!.requestStatus()
    }
    // [END media-control-channel]
    
    func deviceManager(deviceManager: GCKDeviceManager!,
        didFailToConnectToApplicationWithError error: NSError!) {
            print("Received notification that device failed to connect to application.")
            
            showError(error)
            deviceDisconnected()
            //     updateButtonStates()
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!,
        didFailToConnectWithError error: NSError!) {
            print("Received notification that device failed to connect.")
            
            showError(error)
            deviceDisconnected()
            // updateButtonStates()
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!,
        didDisconnectWithError error: NSError!) {
            print("Received notification that device disconnected.")
            
            if (error != nil) {
                showError(error)
            }
            
            deviceDisconnected()
            // updateButtonStates()
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!,
        didReceiveApplicationMetadata metadata: GCKApplicationMetadata!) {
            applicationMetadata = metadata
    }
    
    
    func deviceManager(deviceManager: GCKDeviceManager!, didReceiveApplicationStatusText applicationStatusText: String!) {
        print ("status message " + applicationStatusText)
    }
    
}



