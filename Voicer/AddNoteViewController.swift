//
//  AddNoteViewController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/18/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var graphView: VoiceGraphView!
    var identifier: String!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var note: Note?
    private var levelTimer: Timer?
    private var finishTimer: Timer?
    
    var levels:[CGFloat]?
    
    // MARK: Lifecycle
    
    deinit {
        levelTimer?.invalidate()
        finishTimer?.invalidate()
        levelTimer = nil
        finishTimer = nil
    }
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifier = String(arc4random()) + ".m4a"
        
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
        
        
        recordButton.addTarget(self, action: #selector(self.startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.stopRecording), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.cancelRecording), for: .touchDragExit)
    }
    
    override func viewDidLayoutSubviews() {
        recordButton.layer.cornerRadius = recordButton.frame.width/2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.unwindToHome {
            guard let _ = note else { return }
            let realm = try! Realm()
            try! realm.write {
                realm.delete(note!)
            }
        }
    }
    
    // MARK: Helper methods
    
    private func prepareAudioRecorder() {
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(identifier)
        
        let settings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            loadRecordingUI()
            checkIfNoteExists()
        } catch {
            // failed to prepare recorder!
            finishRecording(success: false)
        }
        
    }
    
    private func loadRecordingUI() {
        playbackButton.isEnabled = false
    }
    
    private func checkIfNoteExists() {
        let realm = try! Realm()
        if let existingNote = realm.object(ofType: Note.self, forPrimaryKey: identifier as AnyObject) {
            note = existingNote
        }
    }
    
    private func loadPermissionErrorUI() {
        print("Please enable audio permissions")
    }
    
    private func loadRecorderErrorUI() {
        print("Unable to start recorder")
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder.stop()
        levelTimer?.invalidate()
        levelTimer = nil
        finishTimer?.invalidate()
        finishTimer = nil
        
        if success {
            //
        } else {
            // recording failed :(
        }
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(false)
        } catch {
            print("can't disable shared recording session")
        }
        
        if let realm = note?.realm {
            try! realm.write {
                note!.timestamp = Date()
            }
        } else {
            let realm = try! Realm()
            try! realm.write {
                note = Note()
                note!.id = identifier
                note!.timestamp = Date()
                realm.add(note!)
            }
        }
        
    }
    
    func levelTimerCallback() {
        audioRecorder.updateMeters()
        if let _ = levels {
            levels!.append(CGFloat(audioRecorder.averagePower(forChannel: 0)))
            graphView.setPathWith(levels: levels!)
        }
    }
    
    func finishTimerCallback() {
        finishTimer = nil
        stopRecording()
    }

    
    //MARK: - User Actions
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(true)
            audioRecorder.record()
            levelTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
            levels = []
            finishTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.finishTimerCallback), userInfo: nil, repeats: false)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
                self.recordButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: nil)
        } catch {
            finishRecording(success: false)
            loadRecorderErrorUI()
        }
        
    }
    
    func stopRecording() {
        guard audioRecorder.isRecording else { return }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
            self.recordButton.transform = CGAffineTransform.identity
            }, completion: { finished in
        })
        finishRecording(success: true)
    }
    
    func cancelRecording() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
            self.recordButton.transform = CGAffineTransform.identity
            }, completion: { finished in
        })
        finishRecording(success: false)
        
    }
    
    
    @IBAction private func playbackNote(_ sender: UIButton) {
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
    
    @IBAction private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

}


extension AddNoteViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playbackButton.isEnabled = true
    }
}
