//
//  CardDrawVC.swift
//  Dash
//
//  Created by yunfeng on 2/2/18.
//  Copyright © 2018 Keane Ruan. All rights reserved.
//

import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices
import Firebase

class CardDrawVC: UIViewController
{
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    var prevVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func storyboardInstance() -> CardDrawVC? {
        return UIStoryboard(name: "CardEdit", bundle: nil).instantiateViewController(withIdentifier: "Draw") as? CardDrawVC
    }
    
    func initialize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
    }
    
    func setupPalette() {
        self.view.backgroundColor = UIColor.white
        
        let paletteView = Palette()
        paletteView.delegate = self as PaletteDelegate
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: self.view.frame.height - paletteHeight, width: self.view.frame.width, height: paletteHeight)
    }
    
    func setupToolBar() {
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - (paletteView?.frame)!.height - height
        let toolBar = ToolBar()
        toolBar.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        toolBar.undoButton?.addTarget(self, action: #selector(self.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(self.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.addTarget(self, action: #selector(self.onClickLoadButton), for: .touchUpInside)
        toolBar.saveButton?.addTarget(self, action: #selector(self.onClickSaveButton), for: .touchUpInside)
        toolBar.saveButton?.setTitle("Done", for: UIControlState())
        toolBar.clearButton?.addTarget(self, action: #selector(self.onClickClearButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
        toolBar.saveButton?.isEnabled = true
        self.view.addSubview(toolBar)
        self.toolBar = toolBar
    }
    
    func setupCanvas() {
        let canvasView = Canvas()
        canvasView.frame = CGRect(x: 20, y: 50, width: self.view.frame.size.width - 40, height: self.view.frame.size.width - 40)
        canvasView.delegate = self as CanvasDelegate
        canvasView.layer.borderColor = UIColor.Palette.blue.cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    @objc func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }
    
    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    @objc func onClickClearButton() {
        self.canvasView?.clear()
    }
    
    
    // MARK: - Image and Photo selection
    fileprivate func showActionSheetForPhotoSelection() {
        let actionSheet = UIActionSheet(title: nil, delegate: self as UIActionSheetDelegate, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Photo from Album", "Take a Photo")
        actionSheet.show(in: self.view)
    }
    
    fileprivate func showPhotoLibrary () {
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
        
        self.present(picker, animated: true, completion: nil)
    }
    
    fileprivate func showCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch (status) {
        case .notDetermined:
            self.presentImagePickerController()
            break
        case .restricted, .denied:
            self.showAlertForImagePickerPermission()
            break
        case .authorized:
            self.presentImagePickerController()
            break
        }
    }
    
    fileprivate func showAlertForImagePickerPermission() {
        let message = "If you want to use camera, you should allow app to use.\nPlease check your permission"
        let alert = UIAlertView(title: "", message: message, delegate: self as UIAlertViewDelegate, cancelButtonTitle: "No", otherButtonTitles: "Allow")
        alert.show()
    }
    
    fileprivate func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func presentImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = .camera
            picker.mediaTypes = [String(kUTTypeImage)]
            self.present(picker, animated: true, completion: nil)
        } else {
            let message = "This device doesn't support a camera"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafeRawPointer)       {
        if didFinishSavingWithError != nil {
            let message = "Saving failed"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        } else {
            let message = "Saved successfuly"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
}


// MARK: - CanvasDelegate
extension CardDrawVC: CanvasDelegate
{
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        
        if let pngImage = image?.asPNGImage() {
            
            //Put image in Storage, not Database
            let imageData = UIImageJPEGRepresentation(pngImage, 0.5)
            var imagePath: String?
            Storage.storage().reference().child("drawings").child(UUID().uuidString).putData(imageData!, metadata: nil) { (metadata, error) in
                if error == nil {
                    imagePath = metadata?.downloadURL()?.absoluteString
                    
                    var card = (self.prevVC as! CardEditVC).card
                    let drawContent = CardContent.init(index: card!.contents.count, content: Draw(imagePath: imagePath!))
                    card!.contents.append(drawContent)
                    card!.formatContents()
                    (self.prevVC as! CardEditVC).tblEdit.reloadData()
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension CardDrawVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType]
        if type as? String != String(kUTTypeImage) {
            return
        }
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true, completion: { [weak self] in
            let cropper = RSKImageCropViewController(image:selectedImage, cropMode:.square)
            cropper.delegate = self
            self?.present(cropper, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - RSKImageCropViewControllerDelegate
extension CardDrawVC: RSKImageCropViewControllerDelegate
{
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.canvasView?.update(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIActionSheetDelegate
extension CardDrawVC: UIActionSheetDelegate
{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return
        }
        
        if buttonIndex == 1 {
            self.showPhotoLibrary()
        } else if buttonIndex == 2 {
            self.showCamera()
        }
    }
}


// MARK: - UIAlertViewDelegate
extension CardDrawVC: UIAlertViewDelegate
{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return
        } else {
            self.openSettings()
        }
    }
}


// MARK: - PaletteDelegate
extension CardDrawVC: PaletteDelegate
{
    //    func didChangeBrushColor(color: UIColor) {
    //
    //    }
    //
    //    func didChangeBrushAlpha(alpha: CGFloat) {
    //
    //    }
    //
    //    func didChangeBrushWidth(width: CGFloat) {
    //
    //    }
    
    
    // tag can be 1 ... 12
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
    
    // tag can be 1 ... 4
    //    func widthWithTag(tag: NSInteger) -> CGFloat {
    //        if tag == 1 {
    //            return 5.0
    //        }
    //        return -1
    //    }
    
    // tag can be 1 ... 3
    //    func alphaWithTag(tag: NSInteger) -> CGFloat {
    //        return -1
    //    }
}
