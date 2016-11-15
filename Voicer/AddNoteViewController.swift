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
    fileprivate var levelGaugeTimer: Timer?
    fileprivate var endNoteTimer: Timer?
    fileprivate var progressTimer: Timer?
    private var recorder: VoiceRecorder!
    private var player: VoicePlayer!
    
    var levels:[CGFloat]?
    
    // MARK: Lifecycle
    
    deinit {
        invalidateTimers()
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifier = String(arc4random()) + ".m4a" // Will remove this
        recorder = VoiceRecorder(filename:identifier)
        
        recordButton.addTarget(self, action: #selector(self.startRecordingButtonTapped), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.stopRecordingButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.cancelRecordingButtonTapped), for: .touchDragExit)
        playbackButton.addTarget(self, action: #selector(self.playbackButtonTapped), for: .touchUpInside)
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
    
    func startRecordingButtonTapped() {
        recorder.startRecording()
        animateStartRecording()
        startRecordingTimers()
        
    }
    
    func stopRecordingButtonTapped() {
        recorder.stopRecording()
    }
    
    func cancelRecordingButtonTapped() {
        recorder.cancelRecording()
    }
    
    func playbackButtonTapped() {
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
    
    private func storeNoteInRealm() {
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
    
    func endNoteTimerCallback() {
        recorder.stopRecording()
        invalidateTimers()
    }
    
    func updateProgress() {
        if let pct = player.currentPercentage {
           graphView.setTime(pct)
        } else {
            invalidateTimers()
        }
    }
    
    private func playbackNote() {
        if (!recorder.isRecording) {
            player.playVoiceNote()
            startPlaybackTimer()
        }
    }
    
    private func animateStartRecording() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: nil)
    }
    
    fileprivate func animateStopRecording() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
            self.recordButton.transform = CGAffineTransform.identity
            }, completion: { finished in
        })
    }
    
    private func startRecordingTimers() {
        levelGaugeTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
        endNoteTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.endNoteTimerCallback), userInfo: nil, repeats: false)
        
    }
    
    private func startPlaybackTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
    }
    
    fileprivate func invalidateTimers() {
        for t in [levelGaugeTimer,endNoteTimer,progressTimer] {
            if t != nil {
                var timer = t
                timer?.invalidate()
                timer = nil
            }
        }
    }

}

extension AddNoteViewController: VoiceRecorderDelegate, VoicePlayerDelegate {
    
    func didStartRecording() {
        //
    }
    
    func didStopRecording() {
        animateStopRecording()
        invalidateTimers()
    }
    func didCancelRecording(error: Error?) {
        animateStopRecording()
        invalidateTimers()
    }
    
    func didStartPlaying() {
        //
    }
    
    func didFinishPlaying() {
        invalidateTimers()
    }
    
    func playerWasCancelledWith(error: Error?) {
        invalidateTimers()
    }
}


//extension AddNoteViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
