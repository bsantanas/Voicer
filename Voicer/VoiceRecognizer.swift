//
//  VoiceRecognizer.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class VoiceRecognizer: NSObject {
    func startRecognizing() {
        //        if recognitionTask != nil {  //1
        //            recognitionTask?.cancel()
        //            recognitionTask = nil
        //        }
        
        // Speech Recognition
        //
        //        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        //
        //        guard let inputNode = audioEngine.inputNode else {
        //            fatalError("Audio engine has no input node")
        //        }  //4
        //
        //        guard let recognitionRequest = recognitionRequest else {
        //            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        //        } //5
        //
        //        recognitionRequest.shouldReportPartialResults = true  //6
        //
        //        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
        //
        //            var isFinal = false  //8
        //
        //            if result != nil {
        //
        //                self.textView.text = result?.bestTranscription.formattedString  //9
        //                isFinal = (result?.isFinal)!
        //            }
        //
        //            if error != nil || isFinal {  //10
        //                self.audioEngine.stop()
        //                inputNode.removeTap(onBus: 0)
        //
        //                self.recognitionRequest = nil
        //                self.recognitionTask = nil
        //
        //            }
        //        })
        //
        //        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        //        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
        //            self.recognitionRequest?.append(buffer)
        //        }
        //        
        //        audioEngine.prepare()  //12
        //        
        //        do {
        //            try audioEngine.start()
        //        } catch {
        //            print("audioEngine couldn't start because of an error.")
        //        }
        //        
        //        textView.text = "Say something, I'm listening!"
    }
    
    func stopRecognizing() {
        //        audioEngine.stop()
        //        recognitionRequest?.endAudio()
    }
}
