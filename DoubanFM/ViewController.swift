//
//  ViewController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocal, ChannelProtocol {

    @IBOutlet weak var imageArtwork: ImagePostEffect!
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var tblSongList: UITableView!
    @IBOutlet weak var progressTime: UILabel!
    @IBOutlet weak var progressBar: UIImageView!

    @IBOutlet weak var btnRepeatMode: RepeatButton!
    @IBOutlet weak var btnPlayPause: PlayButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!

    var eHttp = HTTPController()
    var channelData: [JSON] = []
    var songData: [JSON] = []

    var imageCache = Dictionary<String,UIImage>()

    var playingIndex: Int = 0
    var isAutoFinishPlay: Bool = true

    var audioPlayer: AVPlayer!
    var playbackObserver: AnyObject?
    var progressTimer: NSTimer?


    func onBlurEffect(imageView: UIImageView?) {
        if (imageView != nil) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame.size = CGSize(width: super.view.frame.width, height: super.view.frame.height)

            imageView!.addSubview(blurView)
        }
    }

    func deviceOrientChanged(sender: NSNotification?) {
        let device = UIDevice.currentDevice()
        print("device.orientation:\(device.orientation.rawValue)");
        switch (device.orientation) {
        case .Portrait:
            break
        case .PortraitUpsideDown:
            break
        case .LandscapeLeft:
            break
        case .LandscapeRight:
            break
        default:
            break
        }

        self.onBlurEffect(imageBg)
    }

    func onStart() {
        self.playbackObserver = self.audioPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 3),
            queue: dispatch_get_main_queue(), usingBlock: self.onUpdateProgress)

        self.audioPlayer.currentItem?.addObserver(self,
            forKeyPath: "status",
            options: NSKeyValueObservingOptions.New,
            context: &self.audioPlayer)
        self.audioPlayer.currentItem?.addObserver(self,
            forKeyPath: "loadedTimeRanges",
            options: NSKeyValueObservingOptions.New,
            context: &self.audioPlayer)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onEos:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: self.audioPlayer.currentItem)
    }

    func onStop() {
        if (nil != self.audioPlayer) {
            if (nil != self.playbackObserver) {
                self.audioPlayer.removeTimeObserver(self.playbackObserver!)
                self.playbackObserver = nil

                self.audioPlayer.currentItem?.removeObserver(self,
                    forKeyPath: "status", context: &self.audioPlayer)
                self.audioPlayer.currentItem?.removeObserver(self,
                    forKeyPath: "loadedTimeRanges", context: &self.audioPlayer)
                NSNotificationCenter.defaultCenter().removeObserver(self,
                    name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer.currentItem)
            }
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
            change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &self.audioPlayer) {
            if (keyPath == "status" && nil != change) {
                if let new_value = change![NSKeyValueChangeNewKey] as? NSNumber {
                    let status = new_value.integerValue
                    switch (status) {
                    case AVPlayerStatus.Failed.rawValue:
                        print("\(__FUNCTION__): status: AVPlayerStatus.Failed");
                        break;
                    case AVPlayerStatus.ReadyToPlay.rawValue:
                        print("\(__FUNCTION__): status: AVPlayerStatus.ReadyToPlay");
                        self.audioPlayer.play()
                        self.btnPlayPause.onPlay()
                        break;
                    case AVPlayerStatus.Unknown.rawValue:
                        print("\(__FUNCTION__): status: AVPlayerStatus.Unknown");
                        break;
                    default:
                        print("\(__FUNCTION__): status: Invalid Value");
                        break;
                    }
                } else {
                    print("\(__FUNCTION__): status: nil");
                }
            }

            if (keyPath == "loadedTimeRanges" && nil != change) {
                if let new_value = change![NSKeyValueChangeNewKey] as? NSArray {
                    if new_value.count > 0 {
                        let range = new_value[0].CMTimeRangeValue
                        print("\(__FUNCTION__): loadedTimeRanges: ",
                            "start=\(CMTimeGetSeconds(range.start))",
                            ", end=\(CMTimeGetSeconds(range.end))",
                            ", duration=\(CMTimeGetSeconds(range.duration))")
                    } else {
                        print("\(__FUNCTION__): loadedTimeRanges: start=nil, end=nil, duration=nil")
                    }
                } else {
                    print("\(__FUNCTION__): loadedTimeRanges: nil")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.progressBar.frame.size.width = CGFloat(0)
        self.progressBar.hidden = true

        self.imageArtwork.onRestartRotation()
        self.onBlurEffect(imageBg)

        self.tblSongList.dataSource = self
        self.tblSongList.delegate = self

        self.eHttp.delegate = self
        self.eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        self.eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")

        // Clear the bg-color of songlist table
        self.tblSongList.backgroundColor = UIColor.clearColor()

        self.btnPlayPause.addTarget(self, action: "onPayPause:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnRepeatMode.addTarget(self, action: "onRepeatMode:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnPrevious.addTarget(self, action: "onPreviousNext:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnNext.addTarget(self, action: "onPreviousNext:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func viewWillAppear(animated: Bool) {
        print("\(__FUNCTION__)")
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "deviceOrientChanged:",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        print("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIDeviceOrientationDidChangeNotification,
            object: nil)
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }

    func onPayPause(btn: PlayButton) {
        if (btn.isPlaying) {
            self.audioPlayer.play()
            self.imageArtwork.onResumeRotation()
        } else {
            self.audioPlayer.pause()
            self.imageArtwork.onPauseRotation()
        }
    }
    func onPreviousNext(btn: UIButton) {
        self.isAutoFinishPlay = false

        switch (self.btnRepeatMode.repeatMode) {
        case 1:
            var newindex = 0
            let count = self.songData.count
            if (count > 1) {
                repeat {
                    newindex = random() % count
                } while (newindex == self.playingIndex)
            }
            self.playingIndex = newindex
            self.onSelectRow(self.playingIndex)
        case 2:
            let count = self.songData.count
            if (btn == self.btnPrevious) {
                self.playingIndex = (self.playingIndex + count - 1) % count
            } else {
                self.playingIndex = (self.playingIndex + 1) % count
            }
            self.onSelectRow(self.playingIndex)
        default:
            // Nothing to do
            usleep(1)
        }
    }
    func onRepeatMode(btn: RepeatButton) {
        var msg = ""
        switch (btn.repeatMode) {
        case 1:
            msg = "随机播放"
        case 2:
            msg = "顺序播放"
        default:
            msg = "逗我呢！"
        }
        self.view.makeToast(message: msg, duration: 0.5, position: "center")
    }
    func onEos(sender: NSNotification?) {
        self.onStop()

        if (self.isAutoFinishPlay) {
            switch (self.btnRepeatMode.repeatMode) {
            case 1:
                var newindex = 0
                let count = self.songData.count
                if (count > 1) {
                    repeat {
                        newindex = random() % count
                    } while (newindex == self.playingIndex)
                }
                self.playingIndex = newindex
                self.onSelectRow(self.playingIndex)
            case 2:
                self.playingIndex++
                if (self.playingIndex >= self.songData.count) {
                    self.playingIndex = 0
                }
                self.onSelectRow(self.playingIndex)
            default:
                // Nothing to do
                usleep(1)
            }
        } else {
            self.isAutoFinishPlay = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let channelController: ChannelController = segue.destinationViewController as! ChannelController
        channelController.delegate = self
        channelController.channelData = self.channelData
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("songData.count: \(self.songData.count)")
        return self.songData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tblSongList.dequeueReusableCellWithIdentifier("songitem")!

        // Clear the bg-color of every item in songlist table
        cell.backgroundColor = UIColor.clearColor()

        let rowData:JSON = self.songData[indexPath.row]
        let title = (rowData["title"].string == nil) ? String("Unknown") : rowData["title"].string!
        let artist = (rowData["artist"].string == nil) ? String("Unknown") : rowData["artist"].string!
        let album = (rowData["albumtitle"].string == nil) ? String("Unknown") : rowData["albumtitle"].string!
        let artist_album = artist + String(" - ") + album
        let artwork_url = (rowData["picture"].string == nil) ?
                                String("http://douban.fm/favicon.ico") :
                                rowData["picture"].string!

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
        self.isAutoFinishPlay = false
        self.playingIndex = indexPath.row
        self.onSelectRow(indexPath.row)
    }

    func onSelectRow(index: Int) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tblSongList.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        let rowData: JSON = self.songData[index]
        let imgUrl = rowData["picture"].string
        let audioUrl = rowData["url"].string

        self.progressBar.frame.size.width = CGFloat(0)
        self.progressBar.hidden = true
        self.onSetImage(imgUrl)
        self.onSetAudio(audioUrl)
    }

    func onSetImage(url: String?) {
        self.imageArtwork.onRestartRotation()  /* Restart the rotation */

        if (url != nil) {
            self.onGetCacheImage(url!, imgView: self.imageArtwork)
            self.onGetCacheImage(url!, imgView: self.imageBg)
        } else {
            // TODO:
        }
    }

    func onSetAudio(url: String?) {
        self.progressTimer?.invalidate()
        self.progressTime.text = "00:00"

        if (url != nil) {
            self.onStop()

            let full_url = NSURL(string: url!)!
            let playItem = AVPlayerItem(URL: full_url)

            if (nil == self.audioPlayer || nil == self.audioPlayer.currentItem) {
                self.audioPlayer = AVPlayer(playerItem: playItem)
            } else {
                self.audioPlayer.replaceCurrentItemWithPlayerItem(playItem)
            }

            self.onStart()

            self.isAutoFinishPlay = true
        } else {
            // TODO:
        }
    }

    func onUpdateProgress(time: CMTime) {
        if (nil == self.audioPlayer.currentItem) {
            return
        }

        let ftime = CMTimeGetSeconds(self.audioPlayer.currentItem!.currentTime())
        if (ftime > 0) {
            let time = Int(ftime)
            let minutes = time / 60
            let seconds = time % 60
            if (minutes <= 99) {
                if (minutes > 9 && seconds > 9) {
                    self.progressTime.text = "\(minutes):\(seconds)"
                } else if (minutes > 9) {
                    self.progressTime.text = "\(minutes):0\(seconds)"
                } else if (seconds > 9) {
                    self.progressTime.text = "0\(minutes):\(seconds)"
                } else {
                    self.progressTime.text = "0\(minutes):0\(seconds)"
                }
            } else {
                self.progressTime.text = "99:59"
            }

            let fduration = CMTimeGetSeconds(self.audioPlayer.currentItem!.duration)
            if (fduration > 0) {
                self.progressBar.frame.size.width = super.view.frame.size.width * CGFloat(ftime/fduration)
                if (self.progressBar.hidden) {
                    self.progressBar.hidden = false
                }
            } else {
                self.progressBar.frame.size.width = CGFloat(0)
                self.progressBar.hidden = true
            }
        } else {
            self.progressBar.frame.size.width = CGFloat(0)
            self.progressBar.hidden = true
        }
    }

    func onGetCacheImage(url: String, imgView: UIImageView) {
        let img: UIImage? = self.imageCache[url]
        if (img == nil) {
            print("\(__FUNCTION__): image isn't cached, get it now!")
            request(.GET, url).response { _, _, data, error in
                if (data != nil) {
                    let new_img = UIImage(data: data! )
                    imgView.image = new_img

                    // Cache this image data
                    self.imageCache[url] = new_img
                } else {
                    // TODO:
                }
            }
        } else {
            print("\(__FUNCTION__): image is cached~")
            imgView.image = img
        }
    }

    func didRecieveResults(results: Result<AnyObject>) {
//        print("RecieveResults:\(results)\n<<<")
//        print("RecieveResults.data:\(results.data)\n<<<")
//        print("RecieveResults.value:\(results.value)\n<<<")
        if (results.value != nil) {
            var json = JSON(results.value!)

            if let channels = json["channels"].array {
                self.channelData = channels
            } else if let song = json["song"].array {
                self.songData = song
                // Reload song list
                self.tblSongList.reloadData()
                self.isAutoFinishPlay = false
                self.onSelectRow(0)
            } else {
                print("No valid data!")
            }
        } else {
            print("Results is nil!")
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

