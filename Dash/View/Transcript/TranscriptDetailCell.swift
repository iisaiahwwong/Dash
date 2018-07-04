//
//  TranscriptDetailCell.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit
protocol TranscriptDetailCellDelegate {
    func transcriptDetailCell(didTap: TranscriptDetailCell, _ viewController: UIViewController)
}

class TranscriptDetailCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var outerView: UIView!
    
    var transcript: Transcript?
    var delegate: TranscriptDetailCellDelegate?
    
    func prepare(transcript: Transcript) {
        self.transcript = transcript
        self.titleLabel.text = transcript.title
        
        // Get first index of searchHelper
        for (extract, willShow) in transcript.extractSearchHelper {
            if willShow {
                self.descriptionLabel.text = extract.extractText
                transcript.extractSearchHelper[extract] = false
                break;
            }
        }
    }
    
    override func prepareForReuse() {
        if let transcript = self.transcript {
            for (extract, _) in transcript.extractSearchHelper {
                self.transcript?.extractSearchHelper[extract] = true
            }
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let popupVC = TranscriptVC.storyboardInstance()!
        popupVC.transcript = self.transcript
        TapticFeedback.feedback.heavy()
        self.delegate?.transcriptDetailCell(didTap: self, popupVC)
    }

    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.delegate = self
        self.outerView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
