//
//  PlayButton.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class PlayButton: UIButton {

    var isPlaying: Bool = true

    let imgPlaying = UIImage(named: "play")
    let imgPaused = UIImage(named: "pause")

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func onClick() {
        self.isPlaying = !self.isPlaying
        if (self.isPlaying) {
            self.setImage(imgPaused, forState: UIControlState.Normal)
        } else {
            self.setImage(imgPlaying, forState: UIControlState.Normal)
        }
    }

    func onPlay() {
        self.isPlaying = true
        self.setImage(imgPaused, forState: UIControlState.Normal)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
