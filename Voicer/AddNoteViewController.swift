//
//  AddNoteViewController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import AVFoundation

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.prepareAudioRecorder()
                        self.loadRecordingUI()
                    } else {
                        self.loadPermissionErrorUI()
                    }
                }
            }
        } catch {
            // failed to get permissions!
        }
    }

    func prepareAudioRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            //audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            loadRecordingUI()
        } catch {
            // failed to prepare recorder!
            finishRecording(success: false)
        }

    }
    
    func loadRecordingUI() {
        playbackButton.isEnabled = false
    }
    
    func loadPermissionErrorUI() {
        print("Please enable audio permissions")
    }
    
    func loadRecorderErrorUI() {
        print("Unable to start recorder")
    }
    
    @IBAction func beginRecordingNote(_ sender: UIButton) {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(true)
            recordButton.setTitle("Recording", for: .normal)
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
            loadRecorderErrorUI()
        }
    }
    
    @IBAction func finishRecordingNote(_ sender: UIButton) {
        finishRecording(success: true)
    }
    
    @IBAction func cancelRecordingNote(_ sender: UIButton) {
        finishRecording(success: false)
    }
    
    @IBAction func playbackNote(_ sender: UIButton) {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.delegate = self
                audioPlayer.play()
            } catch {
                print("Couldn't open player")
            }
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        
        if success {
            recordButton.setTitle("Tap to Retry", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(false)
        } catch {
            print("can't disable shared recording session")
        }

    }
    
}


extension AddNoteViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playbackButton.isEnabled = true
    }
}
