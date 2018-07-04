//
//  VoteViewCell.swift
//  Dash
//
//  Created by Isaiah Wong on 1/2/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit

class VoteViewCell: UITableViewCell {
    @IBOutlet weak var pollView: PollView!
    
    func changeView(vote: Vote) {
        pollView.titleLabel.text = vote.title
        pollView.VoteCardContainer.backgroundColor = UIColor.Palette.lightGreen
        pollView.tableView.backgroundColor = UIColor.Palette.lightGreen
        pollView.titleLabel.backgroundColor = UIColor.Palette.lightGreen
        pollView.titleLabel.borderStyle = UITextBorderStyle.none
        pollView.titleLabel.isUserInteractionEnabled = false;
        pollView.doneBtn.isHidden = true
        pollView.addBtn.isHidden = true
        pollView.voteBtn.isHidden = false;
        pollView.disableEditing = true
        pollView.pollActive = true;
        pollView.editTable = false;
        pollView.tableView.reloadData()
    }
    
    func normalView() {
        pollView.card = nil
        pollView.vote = nil
        pollView.contentIndex = nil
        pollView.titleLabel.text = nil
        
        pollView.voteBtn.isHidden = true;
        pollView.VoteCardContainer.borderColor = UIColor.Palette.lightGreen
        pollView.VoteCardContainer.backgroundColor = UIColor.white
        pollView.editTable = true;
        pollView.pollActive = false;
        pollView.doneBtn.isHidden = false
        pollView.addBtn.isHidden = false
        pollView.voteBtn.isHidden = true;
        pollView.disableEditing = false
        pollView.titleLabel.isUserInteractionEnabled = true;
//        pollView.tableView.reloadData()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
