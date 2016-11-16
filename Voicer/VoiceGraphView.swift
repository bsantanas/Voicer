//
//  VoiceGraphView.swift
//  Voicer
//
//  Created by Bernardo Santana on 11/2/16.
//  Copyright © 2016 Bernardo Santana. All rights reserved.
//

import UIKit

class VoiceGraphView: UIView {
    
    private var paths = [UIBezierPath]()
    private let MAX_SAMPLES = 80
    private var percentage:Float = 0


    override func draw(_ rect: CGRect) {
        
        guard paths.count > 0 else { return }
        
        let context = UIGraphicsGetCurrentContext()
        let count = Float(paths.count)
        paths.enumerated().forEach({
            let color = Float($0.0)/count < percentage ? UIColor(red: 19/255, green: 131/255, blue: 152/255, alpha: 1).cgColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1).cgColor
            context?.setStrokeColor(color)
            $0.1.stroke()
        })
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
        
//        path = UIBezierPath(interpolating: points)
        setNeedsDisplay()
    }
    
    func setSinePathWith(levels:[CGFloat]) {
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
        let x = stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(MAX_SAMPLES))
        
        let points = Array(zip(signal, x)).map({ return CGPoint(x:$1,y:$0) })
        
        paths = [UIBezierPath(interpolating: points)]
        setNeedsDisplay()
    }
    
    func setBarsPathWith(levels:[CGFloat]) {
        var y = levels
        let min = y.min()
        let max = y.max()
        guard max! - min! > 0 && y.count > 0 else { return }
        
        let drawingHeight = (bounds.height/2) * 0.9  // 90% of the drawable height
        
        // Normalizing Y
        y = y.map({ ($0 - min!) / (max! - min!) })
        
        if y.count < MAX_SAMPLES*2 {
            for _ in y.count...MAX_SAMPLES*2 {
                y.append(0)
            }
        } else {
            var aux = [CGFloat]()
            let step = CGFloat(y.count)/CGFloat(MAX_SAMPLES*2)
            for i in 0..<MAX_SAMPLES*2-1 {
                let start = Int(CGFloat(i)*step)
                let end = Int(CGFloat(i+1)*step)
                let mean = y[start..<end].reduce(0, { result,value in
                    return result + value }) / CGFloat(end - start)
                aux.append(mean)
            }
            y = aux
        }
        
        
        let carrier = (1..<MAX_SAMPLES*2).map({ pow(-1,CGFloat($0)) })
        let amplitude = drawingHeight
        let signal = zip(carrier,y).map({ return ($0 * $1 * amplitude) + bounds.height/2 })
        
        // Get time series (X values)
        var x = Array(stride(from: 0, to: bounds.width, by: bounds.width/CGFloat(MAX_SAMPLES)))
        x = zip(x,x).flatMap({ [$0.0,$0.1] })
        let points = Array(zip(signal, x)).map({ return CGPoint(x:$1,y:$0) })
        
        let paths: [UIBezierPath] = stride(from: 0, to: 2*MAX_SAMPLES-2, by: 2).map({
            let path = UIBezierPath()
            path.move(to: points[$0])
            path.addLine(to: points[$0+1])
            return path
        })
        self.paths = paths
        setNeedsDisplay()
    }
    
    func setTime(_ pct:Float) {
        percentage = pct
        setNeedsDisplay()
    }
    
    func clearGraph() {
        paths = []
        setNeedsDisplay()
    }
}
