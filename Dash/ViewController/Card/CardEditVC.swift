//
//  CardEditVC.swift
//  Dash
//
//  Created by Keane Ruan on 15/12/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit
import RichEditorView

let GetCardContentUpdates = "com.card.get.update.cards.content"

typealias CardCompletion = () -> Void

class CardEditVC: UIViewController {
    //MARK: Properties
    @IBOutlet weak var editLbl: UILabel!
    @IBOutlet var txtArea: RichEditorView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lastEditLbl: UILabel!
    @IBOutlet weak var tblEdit: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPopUp: UIButton!
    @IBOutlet weak var btnDraw: UIButton!
    
    var selectedCellIndexPath: IndexPath?
    var indexPaths: [IndexPath : Int] = [:]
    
    var dash: Dash?
    var card: Card?
    var vote: Vote?
    var draw: Draw?
    var isNew: Bool = false
    
    var cellHeight: Int = 100
    
    var GetCardContentsKey = Notification.Name(rawValue: GetCardContentUpdates)
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        return toolbar
    }()
    
    var toolbarOptions: [RichEditorOptionItem] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    @IBAction func close(_ sender: Any) {
        //TODO: +K Follow up section
        let content = txtArea.html,
            title = txtTitle.text!
            //section = "",
            //createdAt = Date()
        
        if title.isEmpty {
            self.dismiss(animated: true, completion: nil)
        }
        else{
            self.card!.title = title
            self.card!.cardContents = content
            if self.isNew {
                self.card?.create(completion: nil)
            }
            else {
                self.card?.update(completion: nil)
            }
            
            let vc = DashDetailsVC.storyboardInstance()!
            vc.fetchData()
            self.dismiss(animated: true, completion: nil)
        }

    }
    @IBAction func popUpOnTouched(_ sender: Any) {
        let popupVC = UIStoryboard(name: "CardEdit", bundle: nil).instantiateViewController(withIdentifier: "CardEditPopUpControls") as! PopUpControlsVC
        
        let button = UIButton()
        var gradientLayer = CAGradientLayer()
        let imageLayer = CALayer()
        imageLayer.backgroundColor = UIColor.clear.cgColor
        // Some Hardcoded tested value
        imageLayer.frame = CGRect(x: 15 , y: 15, width: 20, height: 20)
        imageLayer.contents = UIImage(named: "cross_blue")?.cgImage
        button.layer.cornerRadius = 25
        button.frame = CGRect.init(x: self.btnPopUp.center.x - 15, y: self.view.bounds.height - 55, width: 50, height: 50)
        button.setGradientBackground(
            gradientLayer: &gradientLayer,
            cornerRadius: 25,
            upperBound: .white,
            lowerBound: .white,
            withImage: imageLayer
        )
        
        popupVC.prevVC = self
        popupVC.button = button
        self.addChildViewController(popupVC)
        popupVC.view.frame = self.view.frame
        TapticFeedback.feedback.heavy()
        self.view.addSubview(popupVC.view)
        popupVC.didMove(toParentViewController: self)
    }
    
    @IBAction func fontStyleOnTouch(_ sender: Any) {
        //focus on first visible txthtml cell
        for cell in tblEdit.visibleCells.reversed() {
            if cell is CardRichCell {
                ((cell as! CardRichCell).richEditor).focus()
            }
        }
        //show format tools
        setupToolbarFontFormat()
    }
    
    @IBAction func addDrawOnTouch(_ sender: Any) {
        let popupVC = CardDrawVC.storyboardInstance()!
        popupVC.prevVC = self
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func addVote() {
        let voteContent = CardContent.init(index: self.card!.contents.count, content: Vote())
        self.card!.contents.append(voteContent)
        self.card!.formatContents()
        self.tblEdit.reloadData()
    }
    
    func formatContents() {
        if let card = self.card {
            let lastContent = card.contents[card.contents.count - 1].content
            if !(lastContent is String) {
                card.contents.append(CardContent(index: card.contents.count, content: ""))
            }
        }
    }
    
    private func setupEditor(){
        //txtArea.delegate = self
        txtTitle.text = card?.title == nil ?  "" : card!.title
//        card?.cardContents == nil ? (txtArea.placeholder = "Type away, don't be shy ;)") : (txtArea.html = card!.cardContents)
        //TODO: +K Add Member Last Modified
        guard let uwCard = card else { return }
        lastEditLbl.text = "last modified on \(uwCard.createdAt == nil ? "today" : uwCard.createdAt.toString(dateFormat: "dd MMMM, hh:mm a"))"
        
        txtArea.inputAccessoryView = toolbar
        
        toolbar.delegate = self
        toolbar.editor = txtArea
        
        showOriginalOptions()

        toolbar.tintColor = UIColor.Palette.blue
        self.tblEdit.estimatedRowHeight = 80
    }
    
    func showOriginalOptions () {
        toolbarOptions = []
        let itemArr: [RichEditorOptionItem] =
            [
//                RichEditorOptionItem(image: UIImage(named: "edit_table"), title: "") { toolbar in
//                    print("<<<<table>>>>")
//                    return
//                },
//                RichEditorOptionItem(image: UIImage(named: "edit_checklist"), title: "") { toolbar in
//                    print("<<<<checklist>>>>")
//                    return
//                },
                RichEditorOptionItem(image: UIImage(named: "edit_font"), title: "") { toolbar in
                    self.setupToolbarFontFormat()
                    return
                },
                RichEditorOptionItem(image: UIImage(named: "edit_add"), title: "") { toolbar in
                    self.view.endEditing(true)
                    self.btnPopUp.sendActions(for: .touchUpInside)
                    return
                },
                RichEditorOptionItem(image: UIImage(named: "edit_draw"), title: "") { toolbar in
                    self.view.endEditing(true)
                    self.btnDraw.sendActions(for: .touchUpInside)
                    return
                }
        ]
        
        for i in 0..<5 {
            toolbarOptions.insert(RichEditorOptionItem(image: nil, title: "") { toolbar in return }, at: 0)
        }
        
        for i in 0..<itemArr.count {
            toolbarOptions.append(itemArr[i])
            if i != 4 {
                for _ in 1...3 {
                    toolbarOptions.append(
                        RichEditorOptionItem(image: nil, title: "") { toolbar in return }
                    )
                }
            }
        }
        toolbar.options = toolbarOptions
    }
    
    func setupToolbarFontFormat() {
        toolbar.options = RichEditorDefaultOption.all
        
        toolbar.options.insert(RichEditorOptionItem(image: UIImage(named: "cross_blue"), title: "") { toolbar in
            self.showOriginalOptions()
            return
        }, at: 0)
    }
    
    func initValues() {
        if let dash = DashVC.selectedDash {
            self.dash = dash
            // TODO: +K Update Section
        }

        // Create Card if nil
        if self.card == nil {
            let dashId = DashVC.selectedDash == nil ? "" : DashVC.selectedDash!.id
            self.card = Card(dashId: dashId, title: "", content: "")
            self.isNew = true
        }
        
        // Adds a new cell if content is empty
        if self.card!.contents.count == 0 {
            self.card!.contents.append(CardContent(index: self.card!.contents.count, content: ""))
            self.tblEdit.reloadData()
        }
        self.formatContents()
    }
    
    @objc func getCardContentUpdates(notification: NSNotification) {
        if let cardContent = notification.userInfo!["CardContent"] as? CardContent {
//            self.card?.contents.append(cardContent)
            self.formatContents()
            self.tblEdit.reloadData()
        }
    }
    
    static func storyboardInstance() -> CardEditVC? {
        return UIStoryboard(name: "CardEdit", bundle: nil).instantiateViewController(withIdentifier: "CardEdit") as? CardEditVC
    }
    
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getCardContentUpdates(notification:)), name: GetCardContentsKey, object: nil)

    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.tableViewBottomConstraint.constant = 30 + keyboardHeight // 30 is the bottom constraint
            self.scrollToBottom()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.tableViewBottomConstraint.constant = 30
        }
    }
    
    func scrollToBottom() {
//        if self.card!.contents.count > 0 {
//            self.tblEdit.scrollToRow(at: IndexPath.init(row: self.card!.contents.count - 1, section: 0), at: .bottom, animated: false)
//        }
    }
    
    //MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        setupEditor()
        
        // Delegates
        self.tblEdit.delegate = self
        self.tblEdit.dataSource = self
        
        createObserver()
    }
}

extension CardEditVC: UITableViewDelegate, UITableViewDataSource, CardRichCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.card?.contents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = self.card!.contents[indexPath.row]
        switch(content.content) {
        case is String:
            return getRichCell(content, tableView, indexPath)
        case is Intent:
            return getIntentCell(content, tableView, indexPath)
        case is Extract:
            return getExtractCell(content, tableView, indexPath)
        case is Vote:
            return getVoteCell(content, tableView, indexPath)
        case is Draw:
            return getDrawCell(content, tableView, indexPath)
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        for (thisIndexPath, height) in indexPaths {
            if thisIndexPath == indexPath {
                return CGFloat(height + 5)
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func getRichCell(_ content: CardContent, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if let richCell = tableView.dequeueReusableCell(withIdentifier: "CardRichCell", for: indexPath) as? CardRichCell {
            richCell.prepare(content: content, toolBar: self.toolbar, indexPath: indexPath)
            richCell.delegate = self
            return richCell
        }
        return UITableViewCell()
    }
    
    func getIntentCell(_ content: CardContent, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if let intentCell = tableView.dequeueReusableCell(withIdentifier: "ExtractPopUpCell", for: indexPath) as? ExtractPopUpCell {
            intentCell.prepare(content: content)
            intentCell.analysedText.textColor = UIColor.white
            intentCell.cardView.backgroundColor = UIColor.Palette.blue
            return intentCell
        }
        return UITableViewCell()
    }
    
    func getExtractCell(_ content: CardContent, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if let extractCell = tableView.dequeueReusableCell(withIdentifier: "CardExtractCell", for: indexPath) as? CardExtractCell {
            guard let extract = content.content as? Extract else {
                return UITableViewCell()
            }
            extractCell.prepare(extract: extract)
            return extractCell
        }
        return UITableViewCell()
    }
    
    func getVoteCell(_ content: CardContent, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if let voteCell = tableView.dequeueReusableCell(withIdentifier: "VoteCell", for: indexPath) as? VoteViewCell {
            let vote = content.content as! Vote
            voteCell.pollView.vote = vote
            voteCell.pollView.card = self.card
            voteCell.pollView.contentIndex = content.index
            if !(vote.title.isEmpty) {
                voteCell.changeView(vote: vote)
            }
            else {
            // Change to normal view
            }
            return voteCell
        }
        return UITableViewCell()
    }
    
    func getDrawCell(_ content: CardContent, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if let drawCell = tableView.dequeueReusableCell(withIdentifier: "CardDrawCell", for: indexPath) as? CardDrawCell {
            guard let draw = content.content as? Draw else {
                return UITableViewCell()
            }
            
            drawCell.prepare(draw: draw, tableView: tableView)
            
            return drawCell
        }
        return UITableViewCell()
    }
    
    // delegate of getting height
    func cardRichCell(cell: CardRichCell, cellHeight: Int, indexPath: IndexPath) {
        self.indexPaths[indexPath] = cellHeight
        self.tblEdit.beginUpdates()
        self.tblEdit.endUpdates()
    }
}

extension CardEditVC: RichEditorToolbarDelegate {
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    /*func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://abc.com/hij", alt: "Gravatar")
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://abc.com", title: "Link")
        }
    }*/
}
