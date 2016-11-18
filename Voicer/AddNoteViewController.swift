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
    fileprivate var _player: VoicePlayer?
    private var player: VoicePlayer? {
        // Obj-C approach to enable safe access to the voice player
        get {
            if _player == nil {
                _player = VoicePlayer(file: self.recorder.fileURL)
            }
            return _player
        }
    }
    var levels = [CGFloat]()
    
    // MARK: Lifecycle
    
    deinit {
        invalidateTimers()
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifier = String(arc4random()) + ".m4a" // Will remove this later
        recorder = VoiceRecorder(filename:identifier)
        recorder.delegate = self
        
        recordButton.addTarget(self, action: #selector(self.recordingButtonTouchDown), for: .touchDown)
        recordButton.addTarget(self, action: #selector(self.recordingButtonTouchUpInside), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(self.recordingButtonTouchUpOutside), for: .touchDragExit)
        playbackButton.addTarget(self, action: #selector(self.playbackButtonTapped), for: .touchUpInside)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture))
        graphView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        graphView.addGestureRecognizer(tap)
        
    }
    
    override func viewDidLayoutSubviews() {
        recordButton.layer.cornerRadius = recordButton.frame.width/2
    }

    
    //MARK: - User Actions
    
    func recordingButtonTouchDown() {
        animateStartRecording()
        self.startRecordingTimers()
        DispatchQueue.global(qos: .default).async {
            self.recorder.startRecording()
            
        }
    }
    
    func recordingButtonTouchUpInside() {
        recorder.stopRecording()
    }
    
    func recordingButtonTouchUpOutside() {
        recorder.cancelRecording()
    }
    
    func playbackButtonTapped() {
        playbackOrPauseNote()
    }
    
    @IBAction private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func handleGesture(pan:UIGestureRecognizer) {
        guard let _ = player else { return }
        
        switch pan.state {
        case .began, .changed:
            let pct = Float(pan.location(in: graphView).x / graphView.frame.width)
            graphView.setTime(pct)
            player!.currentPercentage = pct
        default:
            return
        }
    }
    
    func handleTap(tap:UITapGestureRecognizer) {
        switch tap.state {
        case .began, .ended :
            playbackOrPauseNote()
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
    
    fileprivate func storeNoteInRealm() {
        if let realm = note?.realm {
            try! realm.write {
                note!.timestamp = Date()
                note?.wavePoints.removeAll()
                levels.forEach({ note?.wavePoints.append(Point(Double($0))) })
                do {
                    try note?.data = NSData(contentsOf: recorder.fileURL)
                } catch {
                    print("couldnt add data to note")
                }
                
            }
        } else {
            let realm = try! Realm()
            try! realm.write {
                note = Note(identifier, timestamp: Date())
                note?.wavePoints.removeAll()
                levels.forEach({ note?.wavePoints.append(Point(Double($0))) })
                do {
                    try note?.data = NSData(contentsOf: recorder.fileURL)
                } catch {
                    print("couldnt add data to note")
                }
                realm.add(note!)
            }
        }
        
    }
    
    func updateLevels() {
        if recorder.isRecording {
            graphView.setTime(1)
            levels.append(recorder.averagePower())
            graphView.setBarsPathWith(levels: levels)
        }
    }
    
    func endNoteTimerCallback() {
        recorder.stopRecording()
        invalidateTimers()
    }
    
    func updateProgress() {

        if let pct = player?.currentPercentage {
            graphView.setTime(pct)
            if pct > 0.98 {
                invalidateTimers()
            }
        }
    }
    
    private func playbackOrPauseNote() {
        guard let _ = player else { return }
        
        if (!recorder.isRecording) {
            if player!.isPlaying {
                player!.pauseVoiceNote()
                invalidateTimers()
            } else {
                player!.playVoiceNote()
                startPlaybackTimer()
            }
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
    
    fileprivate func startRecordingTimers() {
        if levelGaugeTimer == nil {
            levelGaugeTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.updateLevels), userInfo: nil, repeats: true)
        }
        if endNoteTimer == nil {
            endNoteTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.endNoteTimerCallback), userInfo: nil, repeats: false)
        }
        
    }
    
    private func startPlaybackTimer() {
        if progressTimer == nil {
            progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func invalidateTimers() {
        
        if let _ = levelGaugeTimer {
            levelGaugeTimer?.invalidate()
            levelGaugeTimer = nil
        }
        
        if let _ = progressTimer {
            progressTimer?.invalidate()
            progressTimer = nil
        }
        
        if let _ = endNoteTimer {
            endNoteTimer?.invalidate()
            endNoteTimer = nil
        }
        
      }
    
    fileprivate func removeRecordedFileFromDirectory() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: recorder.fileURL.path)
        } catch let error {
            print("Could not delete file \(error)")
        }
    }

}

extension AddNoteViewController: VoiceRecorderDelegate, VoicePlayerDelegate {
    
    func didStartRecording() {
        progressTimer?.invalidate()
        _player = nil
        levels = []
    }
    
    func didStopRecording() {
        invalidateTimers()
        animateStopRecording()
        storeNoteInRealm()
    }
    
    func didCancelRecording(error: Error?) {
        animateStopRecording()
        invalidateTimers()
        levels = []
        graphView.clearGraph()
        removeRecordedFileFromDirectory()
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
