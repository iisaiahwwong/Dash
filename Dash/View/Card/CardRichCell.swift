//
//  CardRichCell.swift
//  Dash
//
//  Created by Isaiah Wong on 31/1/18.
//  Copyright © 2018 Isaiah Wong. All rights reserved.
//

import UIKit
import RichEditorView

protocol CardRichCellDelegate {
    func cardRichCell(cell: CardRichCell, cellHeight: Int, indexPath: IndexPath)
}

class CardRichCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var richEditor: RichEditorView!
    
    var toolBar: RichEditorToolbar?
    
    var indexPath: IndexPath?
    var delegate: CardRichCellDelegate?

    var content: CardContent?
    var cardContents: String?
    
    // MARK: Method
    func prepare(content: CardContent, toolBar: RichEditorToolbar, indexPath: IndexPath) {
        self.content = content
        self.toolBar = toolBar
        self.indexPath = indexPath
        setupEditor()
    }
    
    private func setupEditor() {
        guard let toolBar = self.toolBar else { return }
        self.richEditor.isScrollEnabled = false
        self.richEditor.inputAccessoryView = toolBar
        toolBar.editor = self.richEditor
        
        self.richEditor.html = content?.content as! String
        
        
        // check if content is empty
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.richEditor.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension CardRichCell: RichEditorDelegate {
    func richEditorTookFocus(_ editor: RichEditorView) {
        print(editor.contentHTML)
        toolBar?.editor = self.richEditor
    }
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        self.content!.content = content
    }
    
    
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.cardRichCell(cell: self, cellHeight: height, indexPath: self.indexPath!)
    }
}
