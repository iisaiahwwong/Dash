//
//  SpeechAPI.swift
//  Dash
//
//  Created by Isaiah Wong on 9/11/17.
//  Copyright © 2017 Isaiah Wong. All rights reserved.
//

import Foundation
import googleapis

typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> (Void)

// MARK: Speech API by GoogleCloud
class SpeechAPI: GoogleCloud {
    // MARK: Properties
    let sampleRate: Int = 16000
    private var streaming = false
    
    private var client : Speech!
    private var writer : GRXBufferedPipe!
    private var call : GRPCProtoCall!
    
    // MARK: Instance
    private static let _speechInstance = SpeechAPI()

    private override init() {
        super.init()
        // Get HOST 
        self.HOST = GoogleCloudHost.Speech.rawValue
    }
    
    private func isKeyAvailable() -> Bool{
        return self.key != nil
    }
    
    // MARK: Shared Instance 
    static func speech() -> SpeechAPI {
        return self._speechInstance
    }
    
    // MARK: Methods
    func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
        if !self.isKeyAvailable() {
            return
        }
        
        if (!streaming) {
            // if we aren't already streaming, set up a gRPC connection
            client = Speech(host: self.HOST)
            writer = GRXBufferedPipe()
            call = client.rpcToStreamingRecognize(withRequestsWriter: writer,
                                                  eventHandler:
                { (done, response, error) in
                    completion(response, error as NSError?)
            })
            // authenticate using an API key obtained from the Google Cloud Console
            call.requestHeaders.setObject(NSString(string: self.key!),
                                          forKey:NSString(string:"X-Goog-Api-Key"))
            // if the API key has a bundle ID restriction, specify the bundle ID like this
            call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!),
                                          forKey:NSString(string:"X-Ios-Bundle-Identifier"))
            
//            print("HEADERS:\(call.requestHeaders)")
            
            call.start()
            streaming = true
            
            // send an initial request message to configure the service
            let recognitionConfig = RecognitionConfig()
            recognitionConfig.encoding =  .linear16
            recognitionConfig.sampleRateHertz = Int32(sampleRate)
            recognitionConfig.languageCode = "en-US"
            recognitionConfig.maxAlternatives = 30
            recognitionConfig.enableWordTimeOffsets = true
            
            let streamingRecognitionConfig = StreamingRecognitionConfig()
            streamingRecognitionConfig.config = recognitionConfig
            streamingRecognitionConfig.singleUtterance = false
            streamingRecognitionConfig.interimResults = true
            
            let streamingRecognizeRequest = StreamingRecognizeRequest()
            streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig
            
            writer.writeValue(streamingRecognizeRequest)
        }
        
        // send a request message containing the audio data
        let streamingRecognizeRequest = StreamingRecognizeRequest()
        streamingRecognizeRequest.audioContent = audioData as Data
        writer.writeValue(streamingRecognizeRequest)
    }
    
    func stopStreaming() {
        if (!streaming) {
            return
        }
        writer.finishWithError(nil)
        streaming = false
    }
    
    func isStreaming() -> Bool {
        return streaming
    }
}
