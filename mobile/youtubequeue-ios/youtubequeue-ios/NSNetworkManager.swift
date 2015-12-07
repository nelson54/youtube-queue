//
//  NSNetworkManager.swift
//  youtubequeue-ios
//
//  Created by Michael on 12/5/15.
//  Copyright © 2015 michaelsimard. All rights reserved.
//

import SwiftyJSON

class NSNetworkManager: NSObject {

    let baseUrl: String = "http://chromecast-queue.herokuapp.com"


    func getQueue(completionHandler: (videoList:Array<Video>) -> Void) {
        let url = NSURL(string: baseUrl + "/rooms/0iKjUBImIL/links")
        print(url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            if let httpRes = response as? NSHTTPURLResponse {
                print("status code=", httpRes.statusCode)
                if httpRes.statusCode == 200 {
                    let json = JSON(data: data!)

                    var videoListArray: Array<Video> = Array()

                    for (index, results): (String, JSON) in json {
                        let video: Video = Video(
                        id: results["id"].string!,
                                image: results["image"].string!,
                                site: results["site"].string!,
                                siteId: results["siteId"].string!,
                                title: results["title"].string!,
                                videoUrl: results["videoUrl"].string!,
                                votes: results["votes"].int!
                        )
                        videoListArray.append(video)
                    }
                    completionHandler(videoList: videoListArray);
                }
            }
        }
        task.resume()
    }


    func upvote(linkId: String, roomId: String, completionHandler: (success:Bool) -> Void) {
        let url = NSURL(string: baseUrl + "/rooms/" + roomId + "/links/" + linkId + "/upvote")
        print(url)

        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            completionHandler(success: true);
        }
        task.resume()


    }


    func downvote(linkId: String, roomId: String, completionHandler: (success:Bool) -> Void) {
        let url = NSURL(string: baseUrl + "/rooms/" + roomId + "/links/" + linkId + "/downvote")
        print(url)

        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            completionHandler(success: true);
        }
        task.resume()
    }

    func addYoutubeLink(link: String, roomId: String, completionHandler: (success:Bool) -> Void) {
        let url = NSURL(string: baseUrl + "/rooms/" + roomId + "/links/")
        print(url)
        
        let dictionary:Dictionary<String,String> = Dictionary(dictionaryLiteral: ("link",link))
        
        let postString:String = self .createpostStringWithDictionary(dictionary)

        print (postString)
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        request.HTTPBody = postData;
        request.HTTPMethod = "POST";
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in
            completionHandler(success: true);
        }
        task.resume()
    }
    
    
    
     func createpostStringWithDictionary(params:Dictionary<String,String>)->String{
        var postString:String = String()
        
        for (key,value) in params {
            
            let cfvalue  = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,value,"","!*'();:@&=+$,/?%#[]",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))

            let nsValue = cfvalue as NSString
            let swiftValue:String = nsValue as String
            postString += key + "=" + value 
            
        }
        return postString
    }
 

}

