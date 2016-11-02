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
    private let MAX_SAMPLES = 80


    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor(red: 125/255, green: 5/255, blue: 151/255, alpha: 1).cgColor)
        path?.stroke()
    }
 
    func setPathWith(levels:[CGFloat]) {
        var y = levels
        let min = y.min()
        let max = y.max()
        guard max! - min! > 0 && y.count > 0 else { return }
        
        let drawingHeight = (bounds.height/2) * 0.9  // 90% of the drawable height
        
       // Subsampling for rendering purposes
//        if y.count > MAX_SAMPLES {
//            var aux = [CGFloat]()
//            let step = CGFloat(y.count)/CGFloat(MAX_SAMPLES)
//            for i in 0..<MAX_SAMPLES-1 {
//                let start = Int(CGFloat(i)*step)
//                let end = Int(CGFloat(i+1)*step)
//                let mean = y[start...end].reduce(0, { result,value in
//                    return result + value
//                }) / (CGFloat(end - start) * step)
//                aux.append(mean)
//            }
//            y = aux
//        }
        
        // Taking only last slice
//        if y.count > MAX_SAMPLES {
//            y = Array(y[y.count-MAX_SAMPLES..<y.count])
//        }
        
         // Normalizing Y
        y = y.enumerated().map({ i,value in
            var val = ((value - min!) / (max! - min!) ) * drawingHeight
            if i % 2 == 0 {
                val *= -1
            }
            return val + bounds.height/2
        })
        
        
        if y.count < MAX_SAMPLES {
            for _ in y.count..<MAX_SAMPLES {
                y.append(bounds.height/2)
            }
        } else {
            y = Array(y[y.count-MAX_SAMPLES..<y.count])
        }
    
        // Get time series (X values)
//        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(y.count))
        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(MAX_SAMPLES))

        let points = Array(zip(y, x)).map({ return CGPoint(x:$1,y:$0) })
        //print(points.count)
        
        path = UIBezierPath(interpolating: points)
        setNeedsDisplay()
    }
    
    func setPathWith2(levels:[CGFloat]) {
        var y = levels
        let min = y.min()
        let max = y.max()
        guard max! - min! > 0 && y.count > 0 else { return }
        
        let drawingHeight = (bounds.height/2) * 0.9  // 90% of the drawable height
        
        // Normalizing Y
        y = y.map({ ($0 - min!) / (max! - min!) })
        
        if y.count < MAX_SAMPLES {
            for _ in y.count..<MAX_SAMPLES {
                y.append(0)
            }
        } else {
            var aux = [CGFloat]()
            let step = CGFloat(y.count)/CGFloat(MAX_SAMPLES)
            for i in 0..<MAX_SAMPLES-1 {
                let start = Int(CGFloat(i)*step)
                let end = Int(CGFloat(i+1)*step)
                let mean = y[start..<end].reduce(0, { result,value in
                    return result + value }) / CGFloat(end - start)
                        aux.append(mean)
            }
            y = aux
        }
        
        let carrier = (1..<MAX_SAMPLES).map({ pow(-1,CGFloat($0)) })
        let amplitude = drawingHeight
        let signal = Array(zip(carrier,y).map({ return ($0 * $1 * amplitude) + bounds.height/2 }))
        
        // Get time series (X values)
        //        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(y.count))
        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(MAX_SAMPLES))
        
        let points = Array(zip(signal, x)).map({ return CGPoint(x:$1,y:$0) })
        //print(points.count)
        
        path = UIBezierPath(interpolating: points)
        setNeedsDisplay()
    }

}
