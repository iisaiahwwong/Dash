//
//  UIImage.swift
//  Countdown
//
//  Created by Isaiah Wong on 3/10/17.
//  Copyright © 2017 Isaiah. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
//        let radius: CGFloat = self.bounds.size.height / 2.0
//        self.layer.cornerRadius = radius
        // TODO: This causes Keyboard and all view to clip
//        self.clipsToBounds = true
    }
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        self.image = nil
        // Check cache for image
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            return
        }
        
        let url = URL(string: urlString)
        let session = URLSession.shared
        session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
    
    func loadImageUsingCacheWithUrlString(urlString: String, completion: @escaping (UIImage) -> ()) {
        self.image = nil
        // Check cache for image
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            completion(cacheImage)
            return
        }
        
        let url = URL(string: urlString)
        let session = URLSession.shared
        session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                    completion(downloadedImage)
                }
            }
        }).resume()
    }
}
