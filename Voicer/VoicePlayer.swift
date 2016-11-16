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
    var file: URL!
    var isPlaying: Bool {
        return (audioPlayer != nil) ? audioPlayer!.isPlaying : false
    }
    var currentPercentage: Float {
        get {
            if let _ = audioPlayer, audioPlayer!.isPlaying {
                return Float(audioPlayer!.currentTime/audioPlayer!.duration)
            }
            return 0
        }
        set(pct) {
            if let _ = audioPlayer {
                if pct >= 0 && pct <= 1 {
                    audioPlayer!.currentTime = TimeInterval(pct)*audioPlayer!.duration
                }
            }
        }
    }
    
    private var isPrepared = false
    private var audioPlayer: AVAudioPlayer!
    
    //MARK: - Lifecycle
    
    init?(file: URL) {
        super.init()
        
        guard let player = preparedNewAudioPlayer(with: file) else { return nil }
        
        self.file = file
        self.audioPlayer = player
        
    }
    
    func playVoiceNote() {
        if let player = audioPlayer {
            if !player.play() {
                print("Couldn't play note")
                delegate?.playerWasCancelledWith(error: nil)
            }
        }
    }
    
    func pauseVoiceNote() {
        if let player = audioPlayer, audioPlayer!.isPlaying {
            player.stop()
        }
    }
    
    private func preparedNewAudioPlayer(with url:URL) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        do {
            try player = AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            if !(player!.prepareToPlay()) {
                print("Couldn't prepare player")
            }
        } catch (let error) {
            print("Couldn't open player \(error)")
        }
        return player
    }

    // MARK: - AVAudioPlayer Delegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.playerWasCancelledWith(error: error)
    }
    
}
