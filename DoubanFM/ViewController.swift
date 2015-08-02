//
//  ViewController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocal, ChannelProtocol {

    @IBOutlet weak var imageArtwork: ImagePostEffect!
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var tblSongList: UITableView!

    var eHttp = HTTPController()
    var channelData: [JSON] = []
    var songData: [JSON] = []

    func onBlurEffect(imageView: UIImageView?) {
        if (imageView != nil) {
            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            var blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)

            imageView!.addSubview(blurView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.imageArtwork.onRotation()
        self.onBlurEffect(imageBg)

        self.tblSongList.dataSource = self
        self.tblSongList.delegate = self

        self.eHttp.delegate = self
        self.eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        self.eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("songData.count: \(self.songData.count)")
        return self.songData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tblSongList.dequeueReusableCellWithIdentifier("songitem") as! UITableViewCell
        let rowData:JSON = self.songData[indexPath.row]
        let title = (rowData["title"].string == nil) ? String("Unknown") : rowData["title"].string!
        let artist_album = ((rowData["artist"].string == nil) ? String("Unknown") : rowData["artist"].string!)
                        + String(" - ")
                        + ((rowData["albumtitle"].string == nil) ? String("Unknown") : rowData["albumtitle"].string!)
        let artwork_url = (rowData["picture"].string == nil) ? String("http://douban.fm/favicon.ico") : rowData["picture"].string!

        // Show strings first
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = artist_album
        cell.imageView?.image = UIImage(named: "detail")

        // Show artwork later
        Alamofire.manager.request(Method.GET, artwork_url).response { (_, _, data, error) -> Void in
            if (data != nil) {
                let img = UIImage(data: data as! NSData)
                cell.imageView?.image = img
            }
        }

        return cell
    }

    func didRecieveResults(results: AnyObject?) {
//        println("RecieveResults:\(results)")
        if (results != nil) {
            var json = JSON(results!)

            if let channels = json["channels"].array {
                self.channelData = channels
            } else if let song = json["song"].array {
                self.songData = song
                // Reload song list
                self.tblSongList.reloadData()
            } else {
                println("No valid data!")
            }
        } else {
            println("Results is nil!")
        }
    }

    func onChangeChannel(channel_id: String?) {
        if (channel_id != nil) {
            let url: String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id!)&from=mainsite"
            self.eHttp.onSearch(url)
        } else {
            // TODO:
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var channelController: ChannelController = segue.destinationViewController as! ChannelController
        channelController.delegate = self
        channelController.channelData = self.channelData
    }
}

