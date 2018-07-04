//
//  SpeechVC.swift
//  Dash
//
//  Created by Isaiah Wong on 10/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis
import SwiftyJSON

typealias SpeechCompletion = () -> Void

class TranscriptVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var transcriptContainer: CardView!
    @IBOutlet weak var transcriptTextView: UITextView!
    @IBOutlet weak var highlightButtonContainer: UIView!
    @IBOutlet weak var highlightButton: UIButton!
    @IBOutlet weak var recordStopButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectWrapper: UIView!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var sectionWrapper: UIView!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var controlWrapper: UIView!
    @IBOutlet weak var controlStackView: UIStackView!
    @IBOutlet weak var projectSectionsStackView: UIStackView!
    
    /** Conditional to track if app is recording. **/
    private var isRecording: Bool = false
    private var audioData: NSMutableData!
    
    /** Conditional to track if app is in Highlight mode. **/
    var isHighlight: Bool = false
    /** Gradient Layer used to overlay views. **/
    var gradientLayer: CAGradientLayer = CAGradientLayer()

    var dash: Dash?
    var transcript: Transcript?
    
    /** Stores all truncated extracts **/
    private var extracts: [Extract] = []
    
    /** Stores the current instance of recording instance extract. **/
    private var extractInstance: Extract!
    
    let cellHeight: CGFloat = 40
    var seconds = 20
    var timer: Timer?
    
    var pulseEffect: LFTPulseAnimation!
    
    // MARK: Methods
    @IBAction func highlightDidTap(_ sender: UIButton) {
        let action: SpeechAction = self.isHighlight ? .endHighlight : .highlight
        self.speechActionHandler(action: action, completion: toggleHighlight)
    }
    
    func toggleHighlight() {
        // Toggle Highlight Variable
        self.isHighlight = !self.isHighlight
    }
    
    @IBAction func close(_ sender: UIButton) {
        speechActionHandler(action: .stop) {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)

            }
        }
    }
    
    @IBAction func toggleAudio(_ sender: UIButton) {
        // Stop audio if is recording
        let action: SpeechAction = isRecording ? .stop : .record
        speechActionHandler(action: action, completion: nil)
    }
    
    static func storyboardInstance() -> TranscriptVC? {
        return UIStoryboard(name: "Transcript", bundle: nil).instantiateViewController(withIdentifier: "Transcript") as? TranscriptVC
    }
    
    static func toNavigationVC(viewController: TranscriptVC) -> UINavigationController{
        return UINavigationController(rootViewController: viewController)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(checkDuration)), userInfo: nil, repeats: true)
    }
    
    @objc func checkDuration() {
        if seconds < 1 {
            seconds = 20
            speechActionHandler(action: .endHighlight, completion: toggleHighlight)
            manageSpeechSession(completion: nil, true)
        }
        else {
            seconds -= 1
        }
    }
    
    /**
     * Create Transcript
     */
    func initValues() {
        if let dash = DashVC.selectedDash {
            self.dash = dash
            // Update Section
            self.projectLabel.text = dash.title
            self.styleProjectBox()
        }
        if self.transcript == nil {
            // Create a new transcript
            if let dash = self.dash {
                self.transcript = Transcript(dashId: dash.id)
                self.transcript?.create(completion: { (status) in
                    DispatchQueue.main.async {
                        self.observeExtract()
                    }
                })
            }
            else {
                // Store in temp zone in firebase
                self.transcript = Transcript(dashId: "")
            }
        }
        else {
            // Interpolate Values
            // Copy Array
            self.titleTextField.text = self.transcript!.title
            if self.transcript!.extracts.count > 0 {
                for item in self.transcript!.extracts {
                    // Copy Extracts
                    self.extracts.append(item)
                }
                self.extracts.sort{ $0.createdAt < $1.createdAt }
                self.tableView.reloadData()
                self.scrollToBottom()
            }
            DispatchQueue.main.async {
                self.observeExtract()
            }
        }
    }
    
    func observeExtract() {
        self.transcript?.observeExtracts(completion: { [weak weakSelf = self] (extract) in
            if weakSelf!.appendUnique(extract: extract) {
                weakSelf!.extracts.sort{ $0.createdAt < $1.createdAt }
                weakSelf!.tableView.reloadData()
                weakSelf!.scrollToBottom()
            }
        })
    }
    
    func appendUnique(extract: Extract) -> Bool {
        for obj in self.extracts {
            if obj.id == extract.id {
                return false
            }
        }
        self.extracts.append(extract)
        return true
    }

    /** Handles Speech Controls. **/
    func speechActionHandler(action: SpeechAction, completion: SpeechCompletion?) {
        // TODO: Complete Switch Actions
        switch(action) {
        case .record:
            onRecord()
        case .stop:
            if let completion = completion {
                onStop(completion: completion)
                break
            }
            onStop(completion: nil)
        case .delete:
            onDelete()
        case .createSection:
            onCreateSection()
        case .highlight:
            if let completion = completion {
                onHighlight(completion: completion)
            }
        case .endHighlight:
            if let completion = completion {
//                print("END HIGHLIGHT")
                onEndHighlight(completion: completion)
            }
        }
    }
    
    /** Handles record operation. **/
    func onRecord() {
        let status = self.recordAudio()
        // Starts timer to track duration
        runTimer()
        if status {
            self.isRecording = !self.isRecording
            updateRecordStopButtonImage(action: .record)
        }
        self.animateButton()
    }
    
    /** Handles stop operation  **/
    func onStop(completion: SpeechCompletion?) {
        let status = self.stopAudio()
        self.timer?.invalidate()
        if status {
            self.isRecording = !self.isRecording
            updateRecordStopButtonImage(action: .stop)
            if self.isHighlight {
                speechActionHandler(action: .endHighlight, completion: toggleHighlight)
            }
            else {
                manageSpeechSession(completion: nil, true)
            }
            self.stopAnimationButton()
            guard let completion = completion else {
                return
            }
            completion()
        }
    }
    
    /** Handles highlight operation  **/
    func onHighlight(completion: SpeechCompletion) {
        // Gives Users Taptic Feedback
        TapticFeedback.feedback.medium()
        /** Start recording if it's not recording **/
        if !self.isRecording {
            self.speechActionHandler(action: .record, completion: nil)
        }
        // Update UI Interface
        self.styleTranscriptContainer(action: .highlight)
        self.styleHighlightButtonColor(action: .highlight)
        completion()
    }
    
    func onEndHighlight(completion: @escaping SpeechCompletion) {
        self.manageSpeechSession(completion: completion, false)
        // Gives Users Taptic Feedback
        TapticFeedback.feedback.medium()
        // Update UI Interface
        self.styleTranscriptContainer(action: .endHighlight)
        self.styleHighlightButtonColor(action: .endHighlight)
    }
    
    /** Handles Create Section operation  **/
    func onCreateSection() {
        
    }
    
    func onDelete() {
        // TODO: Delete Previous Exract
    }
    
    /**
     * Calls Starts AudioController for recording. Calls SpeechAPI
     **/
    func recordAudio() -> Bool {
        if SpeechAPI.speech().isStreaming() {
            return false
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        // Initialise audioData
        self.audioData = NSMutableData()
        let sampleRate = SpeechAPI.speech().sampleRate
        _ = AudioController.audio().prepare(specifiedSampleRate: sampleRate)
        // Status code 0 | working, return true
        return AudioController.audio().start() == 0
    }
    
    /**
     * Stops recording function
     **/
    func stopAudio() -> Bool {
        let status = AudioController.audio().stop()
        SpeechAPI.speech().stopStreaming()
        // Status code 0 | working, return true
        return status == 0
    }
    
    func scrollToBottom() {
        if extracts.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.extracts.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
   
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareInterface()
        // Set delegates
        AudioController.audio().delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.titleTextField.delegate = self
        initValues()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.backView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start Recording Audio
        speechActionHandler(action: .record, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.transcript?.removeObserverExtract()
    }
}

// MARK: Extension Audio Controller
extension TranscriptVC: AudioControllerDelegate {
    func getExtract(response: StreamingRecognitionResult) {
//        print("GET EXTRACT")
        // TODO: Extract
        // Instantiate new instance if extractInstance is nil
        if extractInstance == nil {
            guard let id = self.transcript?.id else {
                return
            }
            guard let user = AuthProvider.auth().getCurrentUserModel() else {
                return
            }
            extractInstance = Extract(transcriptId: id, userId: user.id, userInitials: user.name.getInitials())
        }
        extractInstance.unprocessedExtract = response
        do {
            try extractInstance.processTranscript()
        }
        catch {
            print("\(error)")
        }
        // Sets Transcript Text
        self.transcriptTextView.text = extractInstance.extractText
    }
    
    // TODO: HANDLE Thing
    func manageSpeechSession(completion: SpeechCompletion?, _ forceTruncate: Bool) {
        // TODO: Capture Recording before allowing end recording
        guard let extract = extractInstance else {
            if let completion = completion {
                completion()
            }
            return
        }
        /** Check if highlight is checked **/
        if let completion = completion, self.isHighlight {
            /** Prevent Trancation of extract if there's not text */
            if !extract.extractBuilder.isEmpty {
                // Get the finalised text
                self.transcriptTextView.text = extract.extractBuilder
                truncateExtractInstance(style: .highlight)
            }
            completion()
            return
        }
        
        if forceTruncate {
            //            print("Before truncate")
            // Get the finalised text
            self.transcriptTextView.text = extract.extractBuilder
            truncateExtractInstance(style: .normal)
        }
    }
    
    /**
     * Truncate Current Recording Extract Instance creating
     * a transcripted extract
     **/
    func truncateExtractInstance(style: ExtractStyle = .normal) {
        guard let selfExtractInstance = self.extractInstance else {
            return
        }
        /** Pass Object by Reference and appends to extracts **/
        selfExtractInstance.extractText = selfExtractInstance.extractBuilder
        if selfExtractInstance.extractText.isEmpty {
            return
        }
        let extract = selfExtractInstance
        extract.extractStyle = style
        if extract.command == .delete && self.extracts.count != 0 {
            self.transcript?.deletePrevious(extracts: &self.extracts)
            self.reload()
            return
        }
        self.extracts.append(extract)
        /** Resets Speech Instance **/
        self.reload()
        
        // TODO: optimise code
        extract.analyseIntent { (extract) -> (Void) in
            /** Saves to Db **/
            self.passToTranscript(extract)
            // Gets the new extract with intents and replace it
            self.extracts = self.extracts.map {
                $0.id == extract.id ? extract : $0
            }
            self.reload()
        }
    }
    
    func reload() {
        self.transcriptTextView.text = "Start Speaking"
        /** Deallocate extractInstance **/
        extractInstance = nil
        /** Reloads Table View **/
        DispatchQueue.main.async {
            self.tableView.reloadData()
            /** Scrolls to bottom**/
            self.scrollToBottom()
        }
    }
    
    func passToTranscript(_ extract: Extract) {
        guard let transcript = self.transcript else {
            return
        }
        // Auto populates to db
        transcript.extracts.append(extract)
        // Pass to parent controller
        NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateTranscript), object: nil, userInfo: ["transcript" : transcript])
    }

    /** Conditional to track if app is recording **/
    func processAudio(_ data: Data) -> Void {
        self.audioData.append(data)
        // Get predefined Sample rate
        let sampleRate = SpeechAPI.speech().sampleRate
        // Spliting chunks to 100ms
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(sampleRate) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (self.audioData.length > chunkSize) {
            SpeechAPI.speech().streamAudioData(audioData, completion:
                { [weak self] (response, error) in
                    /** Assigns class variable **/
                    guard let strongSelf = self else {
                        return
                    }
                    /** Handles request errors **/
                    if let error = error {
                        strongSelf.speechActionHandler(action: .stop, completion: nil)
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    /** Exit out of closure when response is nil **/
                    guard let response = response else {
                        print(Message.googleabandon.description())
                        return
                    }
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult {
                            // extract speech
                            strongSelf.getExtract(response: result)
                            strongSelf.manageSpeechSession(completion: nil, false)
                        }
                    }
            })
            // Resets
            self.audioData = NSMutableData()
        }
    }
}

/** MARK: Table Extension **/
extension TranscriptVC: UITableViewDelegate, UITableViewDataSource {
    /** Returns truncated extracts **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extracts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let extract = extracts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExtractCell", for: indexPath) as! ExtractCell
        cell.prepare(extract: extract, transcriptVC: self)
        return cell
    }
}

extension TranscriptVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let title = self.titleTextField.text, !title.isEmpty {
            self.transcript?.title = title
            self.transcript?.updateTitle({ (status) in
                if status {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: UpdateTranscript), object: nil, userInfo: ["transcript" : self.transcript])
                }
            })
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
