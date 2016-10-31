//
//  SwipeInteractionController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/31/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    func wireTo(_ viewController: UIViewController) {
        self.viewController = viewController
        prepareGestureRecognizerIn(viewController.view)
    }
    
    private func prepareGestureRecognizerIn(_ view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleGesture(gestureRecognizer:)))
        gesture.edges = .right
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
            
        case .began:
            // 2
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            
        case .changed:
            // 3
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            // 4
            interactionInProgress = false
            cancel()
            
        case .ended:
            // 5
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }

}
