//
//  ViewController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocal {

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

        imageArtwork.onRotation()
        onBlurEffect(imageBg)

        tblSongList.dataSource = self
        tblSongList.delegate = self

        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
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
        var cell = tblSongList.dequeueReusableCellWithIdentifier("songitem") as! UITableViewCell

        var rowData:JSON = self.songData[indexPath.row]
        var title = (rowData["title"].string == nil) ? String("Unknown") : rowData["title"].string!
        var artist_album = ((rowData["artist"].string == nil) ? String("Unknown") : rowData["artist"].string!)
                        + String(" - ")
                        + ((rowData["albumtitle"].string == nil) ? String("Unknown") : rowData["albumtitle"].string!)
        var artwork_url = (rowData["picture"].string == nil) ? String("http://douban.fm/favicon.ico") : rowData["picture"].string!

        // Show strings first
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = artist_album

        // Show artwork later
        Alamofire.manager.request(Method.GET, artwork_url).response { (_, _, data, error) -> Void in
            if (data != nil) {
                var img = UIImage(data: data as! NSData)
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
}

