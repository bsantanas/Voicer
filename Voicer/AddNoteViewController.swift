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
import Speech

class AddNoteViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var graphView: VoiceGraphView!
    @IBOutlet weak var textView: UITextView!
    
    var identifier: String!
    private var note: Note?
    private var levelTimer: Timer?
    private var finishTimer: Timer?
    private var sliderTimer: Timer?
    private weak var recorder = VoiceRecorder.sharedInstance
    
    // Speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
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
        
        recordButton.addTarget(self, action: #selector(self.startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.stopRecording), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.cancelRecording), for: .touchDragExit)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
        graphView.addGestureRecognizer(pan)
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
//        let tap = TouchDownGestureRecognizer(target: self, action: #selector(self.handleGesture))
//        graphView.addGestureRecognizer(tap)
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
    
        
    private func loadRecordingUI() {
        playbackButton.isEnabled = false
    }
    
    private func checkIfNoteExists() {
        let realm = try! Realm()
        if let existingNote = realm.object(ofType: Note.self, forPrimaryKey: identifier as AnyObject) {
            note = existingNote
        }
    }
    
    private func finishRecording(success: Bool) {
        asdf
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
        if let _ = levels {
            graphView.setTime(1)
            levels!.append(recorder.averagePower())
            graphView.setBarsPathWith(levels: levels!)
        }
    }
    
    func finishTimerCallback() {
        finishTimer = nil
        stopRecording()
    }
    
    func updateSlider() {
        if audioPlayer.isPlaying {
           graphView.setTime(Float(audioPlayer.currentTime/audioPlayer.duration))
        } else {
            sliderTimer?.invalidate()
            sliderTimer = nil
        }
    }
    
    func playbackNote() {
        if (!audioRecorder.isRecording){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                audioPlayer.delegate = self
            } catch {
                print("Couldn't open player")
            }
            guard let _ = audioPlayer else { return }
            audioPlayer.prepareToPlay()
            sliderTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            audioPlayer.play()
        }
    }

    
    //MARK: - User Actions
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        print("speech recognizer changed to " + (available ? "available" : "disabled"))
        
    }
    
    
    @IBAction private func playbackNoteButton(_ sender: UIButton) {
        playbackNote()
    }
    
    @IBAction private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func slide(_ slider: UISlider) {
        guard let _ = audioPlayer else { return }
        audioPlayer.currentTime = TimeInterval(slider.value)
        
    }
    
    func handleGesture(pan:UIGestureRecognizer) {
        guard let _ = audioPlayer else { return }
        switch pan.state {
        case .began, .changed:
            let pct = Float(pan.location(in: graphView).x / graphView.frame.width)
            graphView.setTime(pct)
            audioPlayer.currentTime = TimeInterval(pct)*audioPlayer.duration
        default:
            return
        }
    }

}


extension AddNoteViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playbackButton.isEnabled = true
    }
}

extension AddNoteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
