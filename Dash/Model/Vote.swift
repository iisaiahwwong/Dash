//
//  Vote.swift
//  Dash
//
//  Created by ITP312 on 20/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//
import Foundation
import Firebase
import UIKit

class Vote {
    // MARK: Properties
    private var _title: String
    private var _voteOptions: [voteOption]
    
//    private var _voteArr: [Vote] = []

    var title: String {
        get {
            return self._title
        }
        set {
            self._title = newValue
        }
    }
    
//    var optionText: String {
//        get{
//            return self._voteOption.optionText
//        }
//        set{
//            self._voteOption.optionText = newValue
//        }
//    }
    var voteOptions: [voteOption]{
        get{
            return self._voteOptions
        }
        set{
            self._voteOptions = newValue
        }
    }
//    var radioBtn: UIImage {
//        get{
//            return self._voteOption.radioBtn
//        }
//    }
    
//    var voteArr: [Vote] {
//        get { return self._voteArr }
//        set { self._voteArr = newValue }
//    }
 
    // MARK: Intializers
    // Seed initializer
    init() {
        self._title = ""
//        self._voteOption = voteOptions(radioBtn: UIImage(named:"Radiobtn0")!, optionText: "")
        self._voteOptions = []
    }
    
    init(title: String, voteOptions: [voteOption]) {
        self._title = title
        self._voteOptions = voteOptions
    }
    
    //database functions
    static func insertOrReplaceVote(_ voteCard: Vote,_ title: String)
    {
        let ref = FirebaseDatabase.Database.database().reference().child("Votes/\(title)")
        for index in 0..<voteCard.voteOptions.count{
            let ref = FirebaseDatabase.Database.database().reference().child("Votes/\(title)/Option \(index)")
            ref.setValue([
                "index" : index,
                "option" : voteCard.voteOptions[index].optionText,
                "voteCount" : 0,
                ])
        }
    }
    
    func map() -> [String : Any] {
        var vote: [String : Any]!
        var options: [[String : Any]] = []
        var index = 0
        
        for option in self.voteOptions {
            options.append(
                [
                    "Option \(index)" : [
                        "index" : index,
                        "option" : option.optionText,
                        "voteCount" : 0,
                    ]
                ]
            )
            index += 1
        }
        vote = [self.title : options]
        return vote
    }
//    static func updateVoteCount(_ index:Int,_ title: String){
//
//        let ref = FirebaseDatabase.Database.database().reference().child("Votes/\(title)/Option \(index)")
//        ref.observeSingleEvent(of: .value) { (snapshot) in
//            for record in snapshot.children.allObjects as! [DataSnapshot]{
////                print(record.value!)
//                if(record.key == "voteCount"){
//                    //+1 voteCount
//                    let newValue = record.value! as! Int + 1;
//                    print("newValue\(newValue)")
//                    ref.updateChildValues(["voteCount":newValue]);
//
//                }
//
//            }
//        }
//
//    }
    static func updateVoteCount(tableView: UITableView, title: String, card: Card, index: Int){
        
        var visableCells = tableView.visibleCells;
        for count in 0..<visableCells.count{
            guard let cell = visableCells[count] as? PollViewCell else{
                fatalError("dequeued cell not pollViewCell")
            }
            let ref = FirebaseDatabase.Database.database().reference().child("dashs/cards/\(card.id)/contents/\(index)/vote/\(title)/\(count)/Option \(count)")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                for record in snapshot.children.allObjects as! [DataSnapshot]{
                    //                print(record.value!)
                    if(record.key == "voteCount" && cell.isChecked == true){
                        //+1 voteCount
                        let newValue = record.value! as! Int + 1;
                        print("voteCount = \(newValue)")
                        ref.updateChildValues(["voteCount":newValue]);
                    }
                }
                
                if(count == visableCells.count - 1){
                    // finished updating votecounts
                    let maxwidth = 200.0;
                    var totalVoteCount = 0;
                    
                    func doneBtnActions(callback : () -> Void){
                        for count in 0..<tableView.visibleCells.count{
//                            guard let cell = visableCells[count] as? PollViewCell else{
//                                fatalError("dequeued cell not PollViewCell")
//                            }
//                            cell.voteText.isUserInteractionEnabled = false;
//                            votes[count].optionText = cell.voteText.text!
                            
                            let ref = FirebaseDatabase.Database.database().reference().child("dashs/cards/\(card.id)/contents/\(index)/vote/\(title)/\(count)/Option \(count)")
                            print("REF1 = \(ref)")
                            ref.observeSingleEvent(of: .value) { (snapshot) in
                                
                                for record in snapshot.children.allObjects as! [DataSnapshot]{
                                    if(record.key == "voteCount"){
                                        //totalling up vote counts
                                        totalVoteCount += record.value! as! Int
                                    }
                                }
                                
                                
                                if(count == tableView.visibleCells.count - 1){
                                    for iteration2 in 0..<tableView.visibleCells.count{
                                        
                                        guard let cell = visableCells[iteration2] as? PollViewCell else{
                                            fatalError("dequeued cell not PollViewCell")
                                        }
                                        let ref2 = FirebaseDatabase.Database.database().reference().child("dashs/cards/\(card.id)/contents/\(index)/vote/\(title)/\(iteration2)/Option \(iteration2)")
                                        print("REF2 = \(ref2)")
                                        ref2.observeSingleEvent(of: .value){ (snapshot) in
                                            for record in snapshot.children.allObjects as! [DataSnapshot]{
                                                
                                                if(record.key == "voteCount"){
                                                    print(" vote COUNT / TOTAL COUNT  \(record.value! as! Int) / \(totalVoteCount)")
                                                    let ratio = record.value! as! Double / Double(totalVoteCount)
                                                    print("RAtio for bar: \(ratio)")
                                                    cell.voteRatioBar.frame.size.width = CGFloat(ratio * maxwidth)
                                                    let value = record.value! as! Int
                                                    let valueString = String(value)
                                                    cell.userBubbleInitials.text = valueString
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    doneBtnActions (){
                        
                    }
                }
            }
            
        }
        
    }

    static func deleteVoteOption(title: String){
        let ref = FirebaseDatabase.Database.database().reference().child("Votes/\(title)")
        ref.removeValue()
    }
    
//    class func interpolate(dict: [String: Any]) -> [[Vote]] {
//        var voteCardArray : [[Vote]] = []
//        for (title, options) in dict {
//            var voteCardDetails : [Vote] = []
//            var title = title
//            var optionsDict = options as! [String : Any]
//            for option in optionsDict {
//                let optionDict = option.value as! [String : Any]
//                var index = optionDict["index"]
//                var optionText = optionDict["option"]
//                var voteCount = optionDict["voteCount"]
//                let options = voteOptions(radioBtn: UIImage(named:"Radiobtn0")!, optionText:optionText as! String )
//                let vote = Vote(title: title, voteOptions: options)
//                voteCardDetails.append(vote)
//            }
//            voteCardArray.append(voteCardDetails)
//        }
//        return voteCardArray
//    }
    
    class func interpolate(dict: [String : Any]) -> Vote {
        var title: String!
        var voteOptions : [voteOption] = []
        for (key, value) in dict {
            title = key
            let array = value as! NSMutableArray
            for option in array {
                let optionDict = option as! [String : Any]
                for (optionKey, optionValue) in optionDict {
                    let optionValueDict = optionValue as! [String : Any]
                    let index = optionValueDict["index"]
                    let optionText = optionValueDict["option"]
                    let voteCount = optionValueDict["voteCount"]
                    let option = voteOption(radioBtn: UIImage(named:"Radiobtn0")!, optionText: optionText as! String, optionIndex: index as! Int)
                    voteOptions.append(option)
                }
            }
        }
        return Vote(title: title, voteOptions: voteOptions)
    }
    
    static func loadVoteCards(onComplete: @escaping ([Vote]) -> Void){
        let ref = FirebaseDatabase.Database.database().reference().child("Votes")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in

            var voteCardArray : [Vote] = []
            for record in snapshot.children.allObjects as! [DataSnapshot]{
                var voteOptions : [voteOption] = []
                let title = record.key;
                for child in record.children.allObjects as! [DataSnapshot]{
                    let index = child.childSnapshot(forPath: "index").value!
                    let optionText = child.childSnapshot(forPath: "option").value!
                    let voteCount = child.childSnapshot(forPath: "voteCount").value!
                    let option = voteOption(radioBtn: UIImage(named:"Radiobtn0")!, optionText:optionText as! String, optionIndex: index as! Int)
                    voteOptions.append(option)
                }
                let voteCard : Vote = Vote(title: title, voteOptions: voteOptions)
                voteCardArray.append(voteCard)
            }
            onComplete(voteCardArray)
            // VoteCardArray contains array of each Vote Card & its details.

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
class voteOption: NSObject {
    
    // MARK: Properties
    private var _radioBtn: UIImage
    private var _optionText: String
    private var _optionIndex: Int
    
    var optionIndex: Int{
        get{
            return self._optionIndex
            
        }
    }
    var radioBtn: UIImage{
        get{
            return self._radioBtn
        }
    }
    var optionText: String{
        get{
            return self._optionText
        }
        set{
            self._optionText = newValue
        }
    }
  
    // MARK: Initializers
    init(radioBtn: UIImage, optionText: String, optionIndex: Int) {
        self._radioBtn = radioBtn
        self._optionText = optionText
        self._optionIndex = optionIndex

    }
}
