//
//  ScanDocumentCell.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class ScanDocumentCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var scanDocument: ScanDocument?
    
    // MARK: Methods
    func prepare(scanDocument: ScanDocument) {
        self.scanDocument = scanDocument
        if let path = scanDocument.imagePath {
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: path)
        }
        self.titleLabel.text = scanDocument.title
        self.descriptionTextView.text = String(scanDocument.textAnnotation.filter { !"\n".contains($0) }) 
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.thumbnail.layer.cornerRadius = 5.0
    }
}
