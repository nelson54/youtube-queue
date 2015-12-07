//
//  VideoCell.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/6/15.
//  Copyright © 2015 michaelsimard. All rights reserved.
//

import UIKit

protocol VideoCellDelegate {
    func downVoteButtonPressed(video:Video)
    func upVoteButtonPressed(video:Video);
}


class VideoCell: UITableViewCell {

    var delegate: VideoCellDelegate?
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    var video:Video?

    @IBAction func downVoteButtonPressed(sender: AnyObject) {
        print ("Downvote Button Pressed")
        
        
        if let delegate = self.delegate {
            delegate.downVoteButtonPressed(video!)        }
    }
    @IBAction func upVoteButtonPressed(sender: AnyObject) {
        print ("Upvote Button Pressed")
        
        if let delegate = self.delegate {
            delegate.upVoteButtonPressed(video!)
        }

    }
    
    
}
