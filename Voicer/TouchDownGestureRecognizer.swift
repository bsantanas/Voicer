//
//  TouchDownGestureRecognizer.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/3/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible
        {
            self.state = .recognized
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
      self.state = .failed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
       self.state = .failed
    }
}
