//
//  ChannelController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

protocol ChannelProtocol {
    func onChangeChannel(channel_id: String?)
}

class ChannelController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tblChannelList: UITableView!

    var delegate: ChannelProtocol?
    var channelData: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.view.alpha = 0.8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("channelData: \(self.channelData.count)")
        return self.channelData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tblChannelList.dequeueReusableCellWithIdentifier("channelitem") as! UITableViewCell
        let rowData:JSON = self.channelData[indexPath.row]
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData:JSON = self.channelData[indexPath.row]
        let channel_id = rowData["channel_id"].stringValue
        self.delegate?.onChangeChannel(channel_id)

        // Exit current viewcontroller
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
