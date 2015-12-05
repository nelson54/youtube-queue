//
//  ViewController.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/4/15.
//  Copyright (c) 2015 michaelsimard. All rights reserved.
//


import UIKit


class ViewController: UIViewController, GCKDeviceScannerListener, GCKDeviceManagerDelegate,
GCKMediaControlChannelDelegate{

    private var applicationMetadata: GCKApplicationMetadata?
    private var selectedDevice: GCKDevice?
    private var deviceManager: GCKDeviceManager?
    private var mediaInformation: GCKMediaInformation?
    private var mediaControlChannel: GCKMediaControlChannel?
    private var deviceScanner: GCKDeviceScanner
    
    required init(coder aDecoder: NSCoder) {
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID:
            kGCKMediaDefaultReceiverApplicationID)
        deviceScanner = GCKDeviceScanner(filterCriteria:filterCriteria)
        super.init(coder: aDecoder)!
    }
    

    override func viewDidLoad() {
    super.viewDidLoad()
        
        deviceScanner.addListener(self)
        deviceScanner.startScan()
        deviceScanner.passiveScan = true
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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