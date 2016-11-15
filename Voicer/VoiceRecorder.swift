//
//  VoiceRecorder.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/10/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import AVFoundation


protocol VoiceRecorderDelegate: class {
    func didStartRecording()
    func didStopRecording()
    func didCancelRecording(error: Error?)
}

class VoiceRecorder:NSObject, AVAudioRecorderDelegate {
    
    // MARK: Vars
    weak var delegate:VoiceRecorderDelegate?
    var filename:String
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private(set) var prepared = false
    
    // MARK: - Lifecicle
    
    init(filename:String) {
        self.filename = filename
        prepareAudioRecorder()
    }
    
    deinit {
        stopRecording()
    }
    
    // MARK: - API 
    
    func startRecording() {
        guard prepared else { prepareAudioRecorder() }
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
            try recordingSession.setMode(AVAudioSessionModeMeasurement)
            try recordingSession.setActive(true, with: .notifyOthersOnDeactivation)
            audioRecorder.record()
            delegate?.didStartRecording()
        } catch(let error){
            delegate?.didCancelRecording(error: error)
        }
        
    }
    
    func stopRecording() {

        guard prepared && audioRecorder.isRecording else { return }
        
        audioRecorder.stop()
        delegate?.didStopRecording()
        
    }
    
    func cancelRecording() {
        guard prepared && audioRecorder.isRecording else { return }
        audioRecorder.stop()
        delegate?.didCancelRecording(error: nil)
    }
    
    func averagePower() -> CGFloat {
        audioRecorder.updateMeters()
        return CGFloat(audioRecorder.averagePower(forChannel: 0))
    }

    // MARK: - Private 
    
    private func finalizeRecorder() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setActive(false)
        } catch (let error) {
            print("Couldn't stop recording session due to \(error)")
        }

    }
    
    private func requestForPermissions() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.prepareAudioRecorder()
                    } else {
                        self.showFailedPermissionsAlert()
                    }
                }
            }
        } catch {
            showFailedPermissionsAlert()
        }
    }
    
    private func prepareAudioRecorder() {
        
        guard AVAudioSession.sharedInstance().recordPermission() == .granted else { requestForPermissions()
            return
        }

        let audioFileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
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
            prepared = true
        } catch (let error) {
            print("Couldn't prepare audio recorder! error \(error)")
            delegate?.didCancelRecording(error: error)
        }
        
    }
    
    private func showFailedPermissionsAlert() {
        print("Show failed permissions alert")
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.didStopRecording()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        delegate?.didCancelRecording(error: error)
    }
}

