//
//  ViewController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imageArtwork: ImagePostEffect!
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var tblSongList: UITableView!

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tblSongList.dequeueReusableCellWithIdentifier("songitem") as! UITableViewCell
        cell.textLabel?.text = "Title: \(indexPath.row)"
        cell.detailTextLabel?.text = "Detail: \(indexPath.row)"
        cell.imageView?.image = UIImage(named: "detail")
        return cell
    }
}

