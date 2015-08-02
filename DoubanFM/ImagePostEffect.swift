//
//  ImagePostEffect.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class ImagePostEffect: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2

        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
    }

    func onRotation() {
        var animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.fromValue = 0.0
        animation.toValue = M_PI * 2.0
        animation.duration = 20
        animation.repeatCount = 1000000

        self.layer.addAnimation(animation, forKey: nil)
    }
}
