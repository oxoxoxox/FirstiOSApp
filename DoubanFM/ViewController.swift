//
//  ViewController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageArtwork: ImagePostEffect!
    @IBOutlet weak var imageBg: UIImageView!

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

