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

    var imageCache = Dictionary<String,UIImage>()

    func onBlurEffect(imageView: UIImageView?) {
        if (imageView != nil) {
            var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            var blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame.size = CGSize(width: super.view.frame.width, height: super.view.frame.height)

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

        // Clear the bg-color of songlist table
        self.tblSongList.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var channelController: ChannelController = segue.destinationViewController as! ChannelController
        channelController.delegate = self
        channelController.channelData = self.channelData
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("songData.count: \(self.songData.count)")
        return self.songData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tblSongList.dequeueReusableCellWithIdentifier("songitem") as! UITableViewCell

        // Clear the bg-color of every item in songlist table
        cell.backgroundColor = UIColor.clearColor()

        let rowData:JSON = self.songData[indexPath.row]
        let title = (rowData["title"].string == nil) ? String("Unknown") : rowData["title"].string!
        let artist_album = ((rowData["artist"].string == nil) ? String("Unknown") : rowData["artist"].string!)
                        + String(" - ")
                        + ((rowData["albumtitle"].string == nil) ? String("Unknown") : rowData["albumtitle"].string!)
        let artwork_url = (rowData["picture"].string == nil) ? String("http://douban.fm/favicon.ico") : rowData["picture"].string!

        // Show strings first
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = artist_album
        // Show default artwork
        cell.imageView?.image = UIImage(named: "detail")

        // Show real artwork later
        if (cell.imageView != nil) {
            self.onGetCacheImage(artwork_url, imgView: cell.imageView!)
        }

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.onSelectRow(indexPath.row)
    }

    func onSelectRow(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tblSongList.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        let rowData: JSON = self.songData[index]
        let imgUrl = rowData["picture"].string
        self.onSetImage(imgUrl)
    }

    func onSetImage(url: String?) {
        self.imageArtwork.onRotation()  /* Reset the rotation */

        if (url != nil) {
            self.onGetCacheImage(url!, imgView: self.imageArtwork)
            self.onGetCacheImage(url!, imgView: self.imageBg)
        } else {
            // TODO:
        }
    }

    func onGetCacheImage(url: String, imgView: UIImageView) {
        let img: UIImage? = self.imageCache[url]
        if (img == nil) {
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                if (data != nil) {
                    println("\(__FUNCTION__): image is cached")
                    let new_img = UIImage(data: data as! NSData )
                    imgView.image = new_img

                    // Cache this image data
                    self.imageCache[url] = new_img
                } else {
                    // TODO:
                }
            })
        } else {
            imgView.image = img
        }
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
                self.onSelectRow(0)
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
}

