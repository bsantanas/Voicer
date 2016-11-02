//
//  VoiceGraphView.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/2/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class VoiceGraphView: UIView {
    
    private var path:UIBezierPath?
    private let MAX_SAMPLES = 150


    override func draw(_ rect: CGRect) {
        path?.stroke()
    }
 
    func setPathWith(levels:[CGFloat]) {
        var y = levels
        let min = y.min()
        let max = y.max()
        guard max! - min! > 0 && y.count > 0 else { return }
        
        let drawingHeight = (bounds.height/2) * 0.9  // 90% of the drawable height
        
       // Subsampling for rendering purposes
        if y.count > MAX_SAMPLES {
            var aux = [CGFloat]()
            let step = CGFloat(y.count)/CGFloat(MAX_SAMPLES)
            for i in 0..<MAX_SAMPLES-1 {
                let start = Int(CGFloat(i)*step)
                let end = Int(CGFloat(i+1)*step)
                let mean = y[start...end].reduce(0, { result,value in
                    return result + value
                }) / (CGFloat(end - start) * step)
                aux.append(mean)
            }
            y = aux
        }
        
         // Normalizing Y
        y = y.enumerated().map({ i,value in
            var val = ((value - min!) / (max! - min!) ) * drawingHeight
            if i % 2 == 0 {
                val *= -1
            }
            return val + bounds.height/2
        })
    
        // Get time series (X values)
        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(y.count))

        let points = Array(zip(y, x)).map({ return CGPoint(x:$1,y:$0) })
        //print(points.count)
        
        path = UIBezierPath(interpolating: points)
        setNeedsDisplay()
    }
}
