//
//  VoiceRecorder.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/10/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class VoiceRecorder: NSObject {
    static let sharedInstance = VoiceRecorder()
    
    weak var delegate:VoiceRecorderDelegate?
    
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
}

protocol VoiceRecorderDelegate: class {
    
}
