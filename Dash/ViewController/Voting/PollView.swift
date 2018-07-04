//
//  MyView.swift
//  Dash
//
//  Created by ITP312 on 10/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

//Fix : DeleteBtn
import UIKit
import Firebase

class PollView: UIView, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var deleteVoteCardBtn: UIButton!
    @IBOutlet weak var VoteCardContainer: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var voteBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
//    var voteCard : Vote = Vote(title: "", voteOptions: [])
//    var voteCardList : [Vote] = []
    var disableEditing : Bool = false
    var pollActive : Bool = false;
    var editTable: Bool = true;
    
    var card : Card!
    var vote : Vote!
    var contentIndex: Int!
    
    @IBAction func addBtn(_ sender: Any) {
        tableView.beginUpdates()
        
        let indexPath:IndexPath = IndexPath(row:(vote.voteOptions.count), section:0)
        
        //new row details
//        let options = voteOptions(radioBtn: UIImage(named:"Radiobtn0")!, optionText: "")
//        let vote = Vote(title: "TitlePassed", voteOptions: options)
//        self.vote = vote
//        voteCardDetails.append(self.vote!)
        
        let option = voteOption(radioBtn: UIImage(named:"Radiobtn0")!, optionText: "", optionIndex:vote.voteOptions.count)
        vote.voteOptions.append(option)
        tableView.insertRows(at: [indexPath], with: .left)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        VoteCardContainer.backgroundColor = UIColor.Palette.lightGreen
        tableView.backgroundColor = UIColor.Palette.lightGreen
        titleLabel.backgroundColor = UIColor.Palette.lightGreen
        titleLabel.borderStyle = UITextBorderStyle.none
        titleLabel.isUserInteractionEnabled = false;
        doneBtn.isHidden = true
        addBtn.isHidden = true
        voteBtn.isHidden = false;
        disableEditing = true
        pollActive = true;
        editTable = false;
        
        //Sender identifier
        deleteVoteCardBtn.restorationIdentifier = titleLabel.text!
        var visableCells = tableView.visibleCells
        //GET TOTAL VOTES OUTSIDE CELL COUNT LOOP?
        for count in 0..<tableView.visibleCells.count{
            guard let cell = visableCells[count] as? PollViewCell else{
                fatalError("dequeued cell not PollViewCell")
            }
            cell.voteText.isUserInteractionEnabled = false;
            vote.voteOptions[count].optionText = cell.voteText.text!
            vote.title = titleLabel.text!
//            print("VOTES: \(voteCardDetails)")
//            Vote.insertOrReplaceVote(voteCard,titleLabel.text!)
            
        }
        
        
//        self.vote?.title = titleLabel.text!
//        self.vote?.voteArr = voteCardDetails
//        if let vote = self.vote {
//            card?.addVote(vote: vote, completion: { _ -> (Void) in return})
//        }
    }
    
    @IBAction func updateVote(_ sender: Any) {
        Vote.updateVoteCount(tableView:tableView, title:titleLabel.text!, card: self.card, index: self.contentIndex)

        for count in 0..<tableView.visibleCells.count{
            guard let cell = tableView.visibleCells[count] as? PollViewCell else{
                fatalError("dequeued cell not PollViewCell")
            }
            cell.voteText.isHidden = true;
            cell.voteRatioBar.isHidden = false;
        }
    }

    
    override func awakeFromNib() {
        voteBtn.isHidden = true;
        VoteCardContainer.borderColor = UIColor.Palette.lightGreen
        titleLabel.backgroundColor = UIColor.Palette.lightGreen
        titleLabel.borderStyle = UITextBorderStyle.none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 325, height: 195)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vote.voteOptions.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("PollViewCell", owner: self, options: nil)?.first as! PollViewCell
        if disableEditing == true
        {
            cell.voteText.isUserInteractionEnabled = false
        }
        cell.voteText.text = vote.voteOptions[indexPath.row].optionText
        cell.radiobtn.image = vote.voteOptions[indexPath.row].radioBtn
        return cell;
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(pollActive == true){
            guard let cell = tableView.cellForRow(at: indexPath) as? PollViewCell else{
                fatalError("The dequeued cell is not an instance of PollViewCell")
            }
            if (cell.isChecked == false){
                cell.radiobtn.image = UIImage(named:"Radiobtn1")
                cell.isChecked = true;
            } else {
                cell.radiobtn.image = UIImage(named:"Radiobtn0")
                cell.isChecked = false;
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editTable;
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //            voteDeleteIndexPath = indexPath
            tableView.beginUpdates()
            vote.voteOptions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
            //            Vote.deleteVoteOption(indexPath.row, "placeholderVoteTitle")
            //            confirmDelete(voteOptionToDelete)
        }
    }


}

