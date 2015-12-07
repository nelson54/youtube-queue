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


class ViewController: UIViewController, GCKDeviceScannerListener, GCKDeviceManagerDelegate,
        GCKMediaControlChannelDelegate, UITableViewDelegate, UITableViewDataSource, VideoCellDelegate {

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
        self .refreshListData()
        //      self.tableView.registerClass(VideoCell.self, forCellReuseIdentifier: "cell")

    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);


    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tappedCastButton(sender: AnyObject) {


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

            presentViewController(alertController, animated: true, completion: nil);
        }
    }

    @IBAction func cast(sender: AnyObject) {

        print("Cast Video")

        // Show alert if not connected.
        if (deviceManager?.connectionState != GCKConnectionState.Connected) {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Not Connected",
                        message: "Please connect to Cast device",
                        preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.init(title: "Not Connected",
                        message: "Please connect to Cast device", delegate: nil, cancelButtonTitle: "OK",
                        otherButtonTitles: "")
                alert.show()
            }
            return
        }

        // [START media-metadata]
        // Define Media Metadata.
        let metadata = GCKMediaMetadata()
        metadata.setString("Hello there", forKey: kGCKMetadataKeyTitle)
        metadata.setString("Insert useful meta data here " +
                "The quick brown fox jumped over the lazy dog",
                forKey: kGCKMetadataKeySubtitle)

        let url = NSURL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/" +
                "sample/images/BigBuckBunny.jpg")
        metadata.addImage(GCKImage(URL: url, width: 480, height: 360))
        // [END media-metadata]

        // [START load-media]
        // Define Media Information.
        let mediaInformation = GCKMediaInformation(
        contentID:
            "https://r1---sn-p5qlsnz6.googlevideo.com/videoplayback?nh=IgpwcjAyLmlhZDI2Kg41MC4yNDguMTE2LjE4OQ&key=yt6&itag=22&mime=video%2Fmp4&mt=1449447346&ratebypass=yes&signature=9F3EF8131C332F76C7A0BA5588B61ABC25468CCC.58D25DBBD579C7B9766BEC4EFD711F7439DEA516&mv=m&ip=75.151.1.209&ms=au&fexp=9408710%2C9412859%2C9416126%2C9416985%2C9417683%2C9420452%2C9422484%2C9422596%2C9422618%2C9423662%2C9423991%2C9424127%2C9424215%2C9424862%2C9425307%2C9425669&source=youtube&upn=GzLoDho1C_I&pl=19&mn=sn-p5qlsnz6&mm=31&dur=210.465&requiressl=yes&id=o-AO3uFnaideGKfWWaes_2r9FFH43yxNlo9mwtVPgfSSMf&expire=1449469089&ipbits=0&sparams=dur%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&initcwndbps=568750&sver=3&lmt=1431856300296476",
                streamType: GCKMediaStreamType.None,
                contentType: "video/mp4",
                metadata: metadata,
                streamDuration: 0,
                mediaTracks: [],
                textTrackStyle: nil,
                customData: nil
        )

        // Cast the media
        mediaControlChannel!.loadMedia(mediaInformation, autoplay: true)
        // [END load-media
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
        networkManager .getQueue() {
            (videoList: Array<Video>) in
            self.youTubeVideoList = videoList;
            self.updateQueueTable()
            [refreshControl.endRefreshing()];
        };
    }
    
    func refreshListData(){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SwiftSpinner.show("Getting queue")
        }
        networkManager .getQueue() {
            (videoList: Array<Video>) in
            self.youTubeVideoList = videoList;
            self.updateQueueTable()

        
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
    
    
    @IBAction func tappedAddButton(sender: AnyObject) {
        
        let alertController:UIAlertController = UIAlertController(title: "URL", message: "enter youtube url", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let addURLAction = UIAlertAction(title: "add", style: .Default) { (_) in
            
            let urlTextField = alertController.textFields![0] as UITextField
     
        
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.3 * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.networkManager .addYoutubeLink(urlTextField.text!, roomId: "0iKjUBImIL", completionHandler: { (success) -> Void in
                    self .refreshListData()
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
    
}


// MARK: GCKDeiceScannerListener

extension ViewController {

    func deviceDidComeOnline(device: GCKDevice!) {
        print("Device found: \(device.friendlyName)")
    }

    func deviceDidGoOffline(device: GCKDevice!) {
        print("Device went away: \(device.friendlyName)")
    }

}


// MARK: UITableViewDelegate

extension ViewController {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

}

// MARK: UITableViewDatasource

extension ViewController {

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

extension ViewController {
    func downVoteButtonPressed(video:Video) {
        self.networkManager .downvote(video.id, roomId: "0iKjUBImIL") { (success) -> Void in
            self .refreshListData()
        }
    
    }

    func upVoteButtonPressed(video:Video) {
        self.networkManager .upvote(video.id, roomId: "0iKjUBImIL") { (success) -> Void in
            self .refreshListData()
        }
}

}


// [START media-control-channel]
// MARK: GCKDeviceManagerDelegate
// [START_EXCLUDE silent]

extension ViewController {

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
        print(metadata.applicationName)
    }



}

