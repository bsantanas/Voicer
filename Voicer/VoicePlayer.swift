//
//  VoicePlayer.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/15/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol VoicePlayerDelegate: class {
    func didStartPlaying()
    func didFinishPlaying()
    func playerWasCancelledWith(error:Error?)
    @objc optional func progressChanged(progress:Float)
}

// MARK: - Voice Player Class

class VoicePlayer: NSObject, AVAudioPlayerDelegate {
    
    // Singleton
    static let shared = VoicePlayer()
    
    // MARK: - Public API
    
    weak var delegate: VoicePlayerDelegate?
    
    var isPlaying: Bool {
        return (audioPlayer != nil) ? audioPlayer!.isPlaying : false
    }
    
    func play(data: NSData) {
        if audioPlayer == nil || audioPlayer?.data != data as Data {
            if let player = preparedNewAudioPlayer(with: data as Data) {
                audioPlayer = player
                playCurrentAudio()
            }
        } else {
            playCurrentAudio()
        }
    }
    
    func pause() {
        if isPlaying {
            audioPlayer?.stop()
        }
    }
    
    var progress:Float {
        get {
            if isPlaying {
                return Float(audioPlayer!.currentTime/audioPlayer!.duration)
            }
            return 0
        }
        
        set(pct) {
            if audioPlayer != nil && (pct >= 0 && pct <= 1) {
                    audioPlayer!.currentTime = TimeInterval(pct)*audioPlayer!.duration
                }
            }
    }
    
    // MARK: - Private
    private var audioPlayer: AVAudioPlayer?
    private var isPrepared = false
    private var timer: Timer?
    
    private override init() { super.init() }

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
    
    private func preparedNewAudioPlayer(with data:Data) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        do {
            try player = AVAudioPlayer(data: data)
            player?.delegate = self
            if !(player!.prepareToPlay()) {
                print("Couldn't prepare player")
            }
        } catch (let error) {
            print("Couldn't open player \(error)")
        }
        return player
    }
    
    private func playCurrentAudio() {
        if audioPlayer == nil || !(audioPlayer!.play()) {
            print("Couldn't play from data")
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
