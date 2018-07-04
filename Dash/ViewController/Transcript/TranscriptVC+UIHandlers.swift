//
//  SpeechVC+UIHandlers.swift
//  Dash
//
//  Created by Isaiah Wong on 8/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

// MARK: UI Methods
extension TranscriptVC {
    // Sets Background Color of Application
    func prepareInterface() {
        // Set Background Color
        self.backView.backgroundColor = UIColor.white
        // Adjust tableview offsets
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
        // Estimate Cell Height
        self.tableView.estimatedRowHeight = self.cellHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.cellHeight
        self.tableView.scrollIndicatorInsets.bottom = self.cellHeight
    }
    
    func styleProjectBox() {
        self.projectWrapper.borderColor = UIColor.Palette.blue
        self.projectWrapper.backgroundColor = UIColor.Palette.lightBlue
        self.projectLabel.textColor = UIColor.Palette.dullBlue
    }
    
    // Updates Transcript Container Color
    func styleTranscriptContainer(action: SpeechAction) {
        switch (action) {
        case .highlight:
            highlightTranscriptContainer()
        case .endHighlight:
            normalTranscriptContainer()
        default:
            break
        }
    }
    
    func highlightTranscriptContainer() {
        transcriptContainer.setGradientBackground(gradientLayer: &self.gradientLayer,
                                                  upperBound: UIColor.Palette.green,
                                                  lowerBound: UIColor.Palette.lightGreen)
        transcriptTextView.font = UIFont(name: "Gotham-Bold", size: transcriptTextView.font!.pointSize)
        transcriptTextView.textColor = UIColor.white
    }
    
    func normalTranscriptContainer() {
        // Removes Gradient From Transcript container
        transcriptContainer.removeGradientBackground(gradientLayer: &self.gradientLayer)
        transcriptTextView.font = UIFont(name: "Gotham-Book", size: transcriptTextView.font!.pointSize)
        transcriptTextView.textColor = UIColor.black
    }
    
    // Updates Button Color
    func styleHighlightButtonColor(action: SpeechAction) {
        if action == .highlight  {
            self.highlightButtonContainer.backgroundColor = UIColor.Button.assertive
            self.highlightButton.backgroundColor = UIColor.Button.assertive
        }
        else if action == .endHighlight {
            self.highlightButtonContainer.backgroundColor = UIColor.Button.highlight
            self.highlightButton.backgroundColor = UIColor.Button.highlight
        }
    }
    
    // Change PlayButton UI
    func updateRecordStopButtonImage(action: SpeechAction) {
        let name: String
        var inset: CGFloat
        switch(action) {
        case .record:
            name = action.toggleRecordStop(action)
            // Adjust insets to original
            inset = 0.0
        case .stop:
            name = action.toggleRecordStop(action)
            // Adjust insets
            inset = 2.2
        default:
            inset = 0.0
            name = "error"
        }
        self.recordStopButton.contentEdgeInsets.left = inset
        if let image = UIImage(named: name) {
            self.recordStopButton.setImage(image, for: .normal)
        }
    }
    
    func animateButton() {
        self.pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius: 60, position: self.recordStopButton.center)
        self.controlStackView.layer.insertSublayer(self.pulseEffect, below: self.recordStopButton.layer)
    }
    
    func stopAnimationButton() {
        guard let pulseEffect = self.pulseEffect else {
            return
        }
        pulseEffect.removeFromSuperlayer()
    }
    
    /**
     * Predefined Cell values 55, 69... Intervals of 14
     **/
    func calculateFrameHeight(string: String) -> CGFloat {
        var height: CGFloat = 40
        height = string.height(withConstrainedWidth: 200, font: transcriptTextView.font!) + height
        if height > 55 {
            height -= 14
        }
        else if height > 97 {
            height -= 42
        }
        //print(height)
        return height
    }
}
