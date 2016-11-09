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
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var note: Note?
    private var levelTimer: Timer?
    private var finishTimer: Timer?
    private var sliderTimer: Timer?
    
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
        
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
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
            graphView.setTime(1)
            levels!.append(CGFloat(audioRecorder.averagePower(forChannel: 0)))
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
    
    func startRecording() {
        

        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
            try recordingSession.setMode(AVAudioSessionModeMeasurement)
            try recordingSession.setActive(true, with: .notifyOthersOnDeactivation)
            audioRecorder.record()
            levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
            levels = []
            finishTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.finishTimerCallback), userInfo: nil, repeats: false)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
                self.recordButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: nil)
        } catch {
            finishRecording(success: false)
            loadRecorderErrorUI()
        }
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Speech Recognition
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = "Say something, I'm listening!"
        
    }
    
    func stopRecording() {
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
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
