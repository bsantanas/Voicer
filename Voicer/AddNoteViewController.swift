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
    @IBOutlet weak var textView: UITextView!
    
    var identifier: String!
    private var note: Note?
    private var levelGaugeTimer: Timer?
    private var endNoteTimer: Timer?
    private var progressTimer: Timer?
    private var recorder: VoiceRecorder!
    private var player: VoicePlayer!
    
    var levels:[CGFloat]?
    
    // MARK: Lifecycle
    
    deinit {
        levelGaugeTimer?.invalidate()
        levelGaugeTimer?.invalidate()
        progressTimer?.invalidate()
        endNoteTimer = nil
        endNoteTimer = nil
        progressTimer = nil
    }
    
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifier = String(arc4random()) + ".m4a" // Will remove this
        recorder = VoiceRecorder(filename:identifier)
        
        recordButton.addTarget(self, action: #selector(self.startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.stopRecording), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.cancelRecording), for: .touchDragExit)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
        graphView.addGestureRecognizer(pan)
        
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
    
    //MARK: - User Actions
    
    func startRecording() {
        recorder.startRecording()
    }
    
    func stopRecording() {
        recorder.stopRecording()
    }
    
    func cancelRecording() {
        recorder.cancelRecording()
    }
    
    @IBAction private func playbackNoteButton(_ sender: UIButton) {
        playbackNote()
    }
    
    @IBAction private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleGesture(pan:UIGestureRecognizer) {
        switch pan.state {
        case .began, .changed:
            let pct = Float(pan.location(in: graphView).x / graphView.frame.width)
            graphView.setTime(pct)
            player.currentPercentage = pct
        default:
            return
        }
    }
    
    // MARK: - Private
        
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
        if let pct = player.currentPercentage {
           graphView.setTime(pct)
        } else {
            sliderTimer?.invalidate()
            sliderTimer = nil
        }
    }
    
    func playbackNote() {
        if (!recorder.isRecording) {
            player.playVoiceNote()
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
