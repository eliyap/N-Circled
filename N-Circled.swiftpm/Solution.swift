//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import CoreGraphics
import simd

struct Solution {
    let spinners: [Spinner]
    
    func grade(attempt: [Spinner], samples: Int) -> Float {
        
        let attemptSamples: [simd_float2] = (0..<samples).map { (sampleNo) in
            let pt: CGPoint = attempt.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
            return simd_float2(x: Float(pt.x), y: Float(pt.y))
        }
        
        let solutionSamples: [simd_float2] = (0..<samples).map { (sampleNo) in
            let pt: CGPoint = spinners.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
            return simd_float2(x: Float(pt.x), y: Float(pt.y))
        }
        
        var score: Float = .zero
        
        for attemptSample in attemptSamples {
            /// Iterate to find the closest point using `simd` instructions.
            var closest: simd_float2 = solutionSamples.first!
            for solutionSample in solutionSamples {
                if simd_distance_squared(attemptSample, solutionSample) < simd_distance_squared(attemptSample, closest) {
                    closest = solutionSample
                }
            }
            
            /// Add the smallest value to the score.
            score += simd_distance(attemptSample, closest)
        }
        
        return score
    }
}

import UIKit.UIColor
extension Solution {
    static let Oval: Solution = Solution(spinners: [
        Spinner(amplitude: 0.2, frequency: -1, phase: .pi / 10, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.6, frequency: +1, phase: .pi / 17, color: UIColor.yellow.cgColor),
    ])
}
