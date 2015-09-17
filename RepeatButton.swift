//
//  RepeatButton.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class RepeatButton: UIButton {

    var repeatMode: Int = 2

    let imgShuffleMode:UIImage? = UIImage(named: "shuffle")
    let imgRepeatListMode:UIImage? = UIImage(named: "repeat")

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        self.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func onClick(sender: RepeatButton) {
        self.repeatMode++

        if (self.repeatMode == 1) {
            self.setImage(self.imgShuffleMode, forState: UIControlState.Normal)
        } else if (self.repeatMode == 2) {
            self.setImage(self.imgRepeatListMode, forState: UIControlState.Normal)
        } else if (self.repeatMode > 2) {
            self.repeatMode = 1
            self.setImage(self.imgShuffleMode, forState: UIControlState.Normal)
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
