//
//  VoicePlayer.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import AVFoundation

protocol VoicePlayerDelegate: class {
    func didStartPlaying()
    func didFinishPlaying()
    func playerWasCancelledWith(error:Error?)
}

class VoicePlayer: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: VoicePlayerDelegate?
    private var file: URL
    private var prepared = false
    private var audioPlayer: AVAudioPlayer!
    var currentPercentage: Float? {
        get {
            if let _ = audioPlayer, audioPlayer.isPlaying {
                return Float(audioPlayer.currentTime/audioPlayer.duration)
            }
            return nil
        }
        set(pct) {
            if let _ = audioPlayer, let _ = pct {
                if pct! >= 0 && pct! <= 1 {
                    audioPlayer.currentTime = TimeInterval(pct!)*audioPlayer.duration
                }
            }
        }
    }
    
    //MARK: - Lifecycle
    
    init(file: URL) {
        self.file = file
        super.init()
        prepareAudioPlayer()
    }
    
    func prepareAudioPlayer() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: file)
            audioPlayer.delegate = self
            if !audioPlayer.prepareToPlay() {
                print("Couldn't prepare player")
                delegate?.playerWasCancelledWith(error: nil)
            }
        } catch {
            print("Couldn't open player")
        }
        
    }
    
    func playVoiceNote() {
        if !audioPlayer.play() {
            print("Couldn't play note")
            delegate?.playerWasCancelledWith(error: nil)
        }
    }

    // MARK: - AVAudioPlayer Delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.playerWasCancelledWith(error: error)
    }
    
}
