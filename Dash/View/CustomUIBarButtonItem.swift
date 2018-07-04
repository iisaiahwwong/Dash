//
//  CustomUIBarButton.swift
//  Countdown
//
//  Created by Isaiah Wong on 30/9/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

class CustomUIBarButtonItem: UIBarButtonItem {
    var userInfo: [String: Any] = [String: Any]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserInfo(userInfo: [String: Any]) {
        self.userInfo = userInfo
    }
}
