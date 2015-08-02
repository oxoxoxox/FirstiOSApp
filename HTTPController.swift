//
//  HTTPController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit

class HTTPController: NSObject {
    var delegate: HttpProtocal?

    func onSearch(url: String) {
        println("\(__FUNCTION__)")
        Alamofire.manager.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) {
            (_, _, data, error) -> Void in
                self.delegate?.didRecieveResults(data)
        }
    }
}

protocol HttpProtocal {
    func didRecieveResults(results: AnyObject?)
}
