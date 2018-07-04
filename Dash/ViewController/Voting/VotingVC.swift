//
//  VotingVC.swift
//  Dash
//
//  Created by ITP312 on 15/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit

class VotingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pollStackView: UIStackView!
    
    //MARK: Properties
    @IBOutlet weak var VoteCardContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var mainView: UIView!
    var disableEditing = false
    var votes : [Vote] = []
    var voteDeleteIndexPath: IndexPath? = nil
    var pollActive = false;
    var pollList = [PollView]()

    //Xib View Properties
    let viewWidth:CGFloat = 350;
    let viewHeight:CGFloat = 200;
    var yPosition:CGFloat = 0;
    var scrollViewContentSize:CGFloat = 0;
    var pollTagCounter = 0;
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var addOptionBtn: UIButton!
    @IBOutlet weak var voteBtn: UIButton!
    
    //MARK: Private Methods
//    @IBAction func VoteCardDone(_ sender: Any) {
//        VoteCardContainer.backgroundColor = UIColor.Palette.lightGreen
//        tableView.backgroundColor = UIColor.Palette.lightGreen
//
//        doneBtn.isHidden = true
//        addOptionBtn.isHidden = true
//        voteBtn.isHidden = false;
//        disableEditing = true
//        pollActive = true;
//        var visableCells = tableView.visibleCells
//        for count in 0..<tableView.visibleCells.count{
//
//            guard let cell = visableCells[count] as? VoteTableViewCell else{
//                fatalError("dequeued cell not votetableviewcell")
//            }
//            cell.voteText.isUserInteractionEnabled = false;
//            votes[count].optionText = cell.voteText.text!
//
//        }
//        Vote.insertOrReplaceVote(votes,"placeholderVoteTitle")
//
//
//    }
    @IBAction func updateVote(_ sender: Any) {
        var visableCells = tableView.visibleCells
        for count in 0..<tableView.visibleCells.count{
            guard let cell = visableCells[count] as? VoteTableViewCell else{
                fatalError("dequeued cell not votetableviewcell")
            }
            if (cell.checked == true){
//                Vote.updateVoteCount(count, "placeholderVoteTitle")
            }
        }
        
    }
    @IBAction func AddNewPoll(_ sender: Any) {
        if let xibView = Bundle.main.loadNibNamed("PollView", owner: self, options: nil)?.first as? PollView{
            xibView.titleLabel.backgroundColor = UIColor.white
            xibView.titleLabel.borderStyle = UITextBorderStyle.none
            xibView.frame.size.width = viewWidth;
            xibView.frame.size.height = viewHeight;
            xibView.center = self.view.center;
            xibView.frame.origin.y = yPosition;
            
            xibView.deleteVoteCardBtn.tag = self.pollTagCounter;
            xibView.tag = self.pollTagCounter;
            self.pollTagCounter += 1
//            xibView.deleteVoteCardBtn.restorationIdentifier = xibView.titleLabel2.text!
            xibView.deleteVoteCardBtn.addTarget(self, action: #selector(VotingVC.deleteVoteCardPressed(sender:)), for: .touchUpInside)
            print("ADDED XIBVIEW = \(xibView)")
            self.scrollView.addSubview(xibView)
            
                
            let spacer:CGFloat = 20
            yPosition += viewHeight + spacer
            scrollViewContentSize += viewHeight + spacer
            self.scrollView.contentSize = CGSize(width:viewWidth,height:scrollViewContentSize)
        }
    }
//    @IBAction func addOption(_ sender: Any) {
//        tableView.beginUpdates()
//        let indexPath:IndexPath = IndexPath(row:(votes.count), section:0)
//        //new row details
//        let options = voteOptions(radioBtn: UIImage(named:"Radiobtn0")!, optionText: "")
//        let vote = Vote(title: "TitlePassed", voteOptions: options)
//        votes.append(vote)
//        tableView.insertRows(at: [indexPath], with: .left)
//        tableView.endUpdates()
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
    
    private func loadVotes(){
        
//        let options = voteOptions(radioBtn: UIImage(named:"Radiobtn1")!, optionText: "text1")
//        //        let radiobtn = UIImage(named: "Radiobtn1")
//        let vote1 = Vote(title: "TitlePassed", voteOptions: options)
//        votes.append(vote1)
        
//        let options2 = voteOptions(radioBtn: UIImage(named:"Radiobtn0")!, optionText: "text2")
//        //        let radiobtn = UIImage(named: "Radiobtn1")
//        let vote2 = Vote(title: "TitlePassed", voteOptions: options2)
//        votes.append(vote2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVotes()
        tableView.dataSource = self
        tableView.delegate = self
        VoteCardContainer.borderColor = UIColor.Palette.lightGreen
        voteBtn.isHidden = true;
        // TODO: Hardcoded login Tobe integrated with main
        if AuthProvider.auth().getCurrentUser() == nil {
            AuthProvider.auth().login(withEmail: "ngjunkiat968@gmail.com", password: "huang5", completion: nil);
        }
        populateVoteCards()
    }
    func populateVoteCards(){
        Vote.loadVoteCards(){
            voteCardArray in

                for i in 0..<voteCardArray.count{
                    //Array of vote cards
                    print(voteCardArray)
                    if let xibView = Bundle.main.loadNibNamed("PollView", owner: self, options: nil)?.first as? PollView{
                        xibView.vote = voteCardArray[i]
                        xibView.titleLabel.text = voteCardArray[i].title
        
                        //set uneditable poll card properties
                        xibView.VoteCardContainer.backgroundColor = UIColor.Palette.lightGreen
                        xibView.tableView.backgroundColor = UIColor.Palette.lightGreen
                        xibView.titleLabel.backgroundColor = UIColor.Palette.lightGreen
                        xibView.titleLabel.borderStyle = UITextBorderStyle.none
                        xibView.titleLabel.isUserInteractionEnabled = false;
                        xibView.doneBtn.isHidden = true
                        xibView.addBtn.isHidden = true
                        xibView.voteBtn.isHidden = false;
                        xibView.disableEditing = true
                        xibView.pollActive = true;
                        xibView.editTable = false;
                        xibView.deleteVoteCardBtn.tag = self.pollTagCounter;
                        xibView.tag = self.pollTagCounter;
                        self.pollTagCounter += 1
                        xibView.deleteVoteCardBtn.restorationIdentifier = xibView.titleLabel.text!
                        xibView.deleteVoteCardBtn.addTarget(self, action: #selector(VotingVC.deleteVoteCardPressed(sender:)), for: .touchUpInside)
                        xibView.frame.size.width = self.viewWidth;
                        xibView.frame.size.height = self.viewHeight;
                        xibView.center = self.view.center;
                        xibView.frame.origin.y = self.yPosition;
                        self.scrollView.addSubview(xibView)

                        let spacer:CGFloat = 20
                        self.yPosition += self.viewHeight + spacer
                        self.scrollViewContentSize += self.viewHeight + spacer
                        self.scrollView.contentSize = CGSize(width:self.viewWidth,height:self.scrollViewContentSize)
                    }
                }

        }

    }
    
    @objc func deleteVoteCardPressed(sender:UIButton){
    
        for view in self.scrollView.subviews as! [UIView]{
            print("viewTAG = \(view.tag)")
            print("buttonTAG = \(sender.tag)")
            
            if view.tag == sender.tag {
                
//                print("BEFOREDELETExx \(sender.restorationIdentifier!)")
                
                view.removeFromSuperview()
                print("GUARD LET TITLE = \(title)")
                guard let title = sender.restorationIdentifier else {
                    return
                }
                print("DELETEING VOTE WITH TITLE = \(title)")
                Vote.deleteVoteOption(title: title)
                
//                let view2 = view as! PollView
//                print(view2.titleLabel2.text!)
            }
        }
        print("END DELETETAGSLOOP")
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
                    cell.backgroundColor = UIColor.clear
                }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return votes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "voteCell", for: indexPath) as? VoteTableViewCell else{
            fatalError("The dequeued cell is not an instance of VoteTableViewCell")
            }
            if disableEditing == true
            {
//                cell.voteText.isUserInteractionEnabled = false
            }
//            cell.voteText.text = votes[indexPath.row].optionText
//            cell.voteCheckBox.image = votes[indexPath.row].radioBtn

            return cell
        }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            voteDeleteIndexPath = indexPath
    
            tableView.beginUpdates()
            votes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
//            Vote.deleteVoteOption(indexPath.row, "placeholderVoteTitle")
//            confirmDelete(voteOptionToDelete)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(pollActive == true){
            guard let cell = tableView.cellForRow(at: indexPath) as? VoteTableViewCell else{
                fatalError("The dequeued cell is not an instance of VoteTableViewCell")
            }
            if (cell.checked == false){
                cell.voteCheckBox.image = UIImage(named:"Radiobtn1")
                cell.checked = true;
            } else {
                cell.voteCheckBox.image = UIImage(named:"Radiobtn0")
                cell.checked = false;
            }
        }
        
        
    }
    

        // Configure the cell...
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    



