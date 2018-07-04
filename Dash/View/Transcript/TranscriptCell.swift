//
//  TranscriptCell.swift
//  Dash
//
//  Created by Isaiah Wong on 2/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

protocol TranscriptCellDelegate {
    func transcriptCell(didTap: TranscriptCell, _ viewController: UIViewController)
}

class TranscriptCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    var transcript: Transcript?
    var delegate: TranscriptCellDelegate?
    
    // MARK: Methods
    func prepare(transcript: Transcript) {
        self.transcript = transcript
        self.titleLabel.text = transcript.title
        self.lastModifiedLabel.text = transcript.lastModified.toString(dateFormat: "dd MMM")
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let popupVC = TranscriptVC.storyboardInstance()!
        popupVC.transcript = self.transcript
        //        popupVC.dash = self.dash
        TapticFeedback.feedback.heavy()
        self.delegate?.transcriptCell(didTap: self, popupVC)
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.delegate = self
        outerView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
