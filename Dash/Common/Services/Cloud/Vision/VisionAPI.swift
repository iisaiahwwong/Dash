//
//  VisionAPI.swift
//  Dash
//
//  Created by Isaiah Wong on 30/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias VisionCompletionHandler = (String) -> (Void)

class VisionAPI: GoogleCloud {
    // MARK: Properties
    let session = URLSession.shared
    
    private static let _visionInstance = VisionAPI()
    
    private override init() {
        super.init()
        // Get HOST
        self.HOST = GoogleCloudHost.Vision.rawValue
    }
    
    private func isKeyAvailable() -> Bool{
        return self.key != nil
    }
    
    // MARK: Shared Instance
    static func vision() -> VisionAPI {
        return self._visionInstance
    }
    
    func queryOCR(with imageBase64: String, completion: @escaping VisionCompletionHandler) {
        if !isKeyAvailable() {
            print("Key is not available")
            return
        }
        // Create our request URL
        let url = URL(string: "\(self.HOST)\(self.key!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        request.httpBody = data
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request, completion) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest, _ completion: @escaping VisionCompletionHandler) {
        // run the request
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            self.analyzeResults(data, completion)
        }
        task.resume()
    }
    
    func analyzeResults(_ dataToParse: Data, _ completion: VisionCompletionHandler) {
        // Use SwiftyJSON to parse results
        do {
            let json = try JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                let error: String = "Error code \(errorObj["code"]): \(errorObj["message"])"
            }
            else {
                let textAnnotation: TextAnnotation!
                // Parse the response
                let responses: JSON = json["responses"][0]
                // Get text annotation
                let json: JSON = responses["textAnnotations"]
                if json != nil {
                    print(json)
                    let description = json[0]["description"].object
                    completion(description as! String)
                }
            }
        }
        catch { }
    }

    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
