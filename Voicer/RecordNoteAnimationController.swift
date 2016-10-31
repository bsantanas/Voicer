//
//  RecordNoteAnimationController.swift
//  Voicer
//
//  Created by Bernardo Santana on 10/31/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class RecordNoteAnimationController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var originFrame = CGRect.zero
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView

        containerView.addSubview(toVC.view)
        
        let center = CGPoint(x:originFrame.midX,y:originFrame.midY)
        
//        let circleMaskPathInitial = UIBezierPath(rect: originFrame)
        let circleMaskPathInitial = UIBezierPath.rectPathWith(center: center, sideH: originFrame.width, sideV: originFrame.height)
        // If point is above center in y adjust extreme point
        let extremePoint = CGPoint(x: center.x, y: center.y /*- toVC.view.bounds.height*/)
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        //let circleMaskPathFinal = UIBezierPath(ovalIn: originFrame.insetBy(dx: -radius, dy: -radius))
        let circleMaskPathFinal = UIBezierPath.circlePathWith(center: center, radius: radius)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toVC.view.layer.mask = maskLayer
        
        CATransaction.begin()
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        CATransaction.setCompletionBlock({
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            toVC.view.layer.mask = nil
        })
        maskLayer.add(maskLayerAnimation, forKey: "path")
        CATransaction.commit()
    }
    
}

extension UIBezierPath {
    class func circlePathWith(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(M_PI), endAngle: -CGFloat(M_PI/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(M_PI/2), endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(M_PI), clockwise: true)
        circlePath.close()
        return circlePath
    }
    
    class func rectPathWith(center: CGPoint, sideH: CGFloat, sideV:CGFloat) -> UIBezierPath {
        let squarePath = UIBezierPath()
        let startX = center.x - sideH / 2
        let startY = center.y - sideV / 2
        squarePath.move(to: CGPoint(x: startX, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + sideH, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + sideH, y: startY + sideV))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX, y: startY + sideV))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.close()
        return squarePath
    }

}
