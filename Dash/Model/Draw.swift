//
//  Draw.swift
//  Dash
//
//  Created by yunfeng on 2/2/18.
//  Copyright © 2018 Keane Ruan. All rights reserved.
//

import Foundation
import Firebase

class Draw { //Avoid using Drawing because the NXDrawKit uses the class name Drawing too
    var image: UIImage?
    var imagePath: String?
    
    init(imagePath: String) { self.imagePath = imagePath }
    
    func map() -> [String : Any] { //to write to Db
        //return this dict to put in Database under card's contents
        return ["imagePath" : self.imagePath]
    }
    
    class func interpolate(dict: [String : Any]) -> Draw { //to read/update db
        let imagePath = dict["imagePath"] as! String

        return Draw(imagePath: imagePath)
    }
}

