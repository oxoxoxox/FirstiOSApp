//
//  HTTPController.swift
//  DoubanFM
//
//  Created by JasonChiang on 8/02/15.
//  Copyright (c) 2015年 JasonChiang. All rights reserved.
//

import UIKit
//import Alamofire

class HTTPController: NSObject {
    var delegate: HttpProtocal?

    func onSearch(url: String) {
        print("\(__FUNCTION__)")
        request(.GET, url).responseJSON { _, _, data in
            self.delegate?.didRecieveResults(data)
        }
    }
}

protocol HttpProtocal {
    func didRecieveResults(results: Result<AnyObject>)
}
