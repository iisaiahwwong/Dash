//
//  ImagePreview.swift
//  Dash
//
//  Created by Isaiah Wong on 2/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit
import Vision
import ImageIO

class ImagePreviewVC: UIViewController {
    @IBOutlet weak var imagePreview: UIImageView!
    
    var image: UIImage!
    var imageToAnalyis : CIImage?
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentifiaction)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()

    // MARK: Methods
    func initialise() {
        guard let ciImage = CIImage(image: self.image) else { fatalError("can't create CIImage from UIImage") }
        imageToAnalyis = ciImage.oriented(forExifOrientation: Int32(self.image.imageOrientation.rawValue))
        // Create vision image request
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(Int32(self.image.imageOrientation.rawValue)))!)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                 try handler.perform([self.textRectangleRequest])
            }
            catch {
                print(error)
            }
        }
    }
    
    func handleTextIdentifiaction (request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation] else {
            print("unexpected result type from VNTextObservation")
            return
        }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            self.imagePreview.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for box in observations {
                guard let chars = box.characterBoxes else {
                    print("no char values found")
                    return
                }
                for char in chars {
                    print(char)
                    let view = self.createBoxView(withColor: UIColor.Palette.blue)
                    view.frame = self.transformRect(fromRect: char.boundingBox, toViewRect: self.imagePreview)
                    //self.imagePreview.image = self.imagePreview.image
                    self.imagePreview.addSubview(view)
                }
            }
        }
    }
    
    func transformRect(fromRect: CGRect , toViewRect: UIView) -> CGRect {
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        return toRect
    }
    
    func createBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    static func storyboardInstance() -> ImagePreviewVC? {
        return UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "ImagePreview") as? ImagePreviewVC
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if let image = self.image {
            self.imagePreview.image = image
        }
        initialise()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
