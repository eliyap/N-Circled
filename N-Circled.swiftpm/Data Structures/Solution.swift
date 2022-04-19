//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import CoreGraphics
import KDTree

struct Solution {
    
    public let spinners: [Spinner]
    
    /// Calculates the partial normalized score (within `[0, 1]`) by taking 
    /// only the first `index` distances into account.
    public static func score(upTo index: Int, of distances: [Double]) -> Double {
        guard 0 <= index && index <= distances.count else {
            assert(false, "Invalid index \(index) ")
            return 0
        }
        
        let scorer = Scorer()
        var score: Double = .zero
        
        for distance in distances[0..<index] {
            score += scorer.normalizedScore(distance: distance)
        }
        
        /// Normalize score.
        score /= Double(distances.count)
        
        return score
    }
    
    /// Given a player's puzzle attempt, samples the resulting IDFT and finds 
    /// the distance from each point to the closest point on the (sampled) 
    /// solution.
    /// 
    /// Returns those distances.
    public func distances(attempt: [Spinner], samples: Int) -> [Double] {
        
        let attemptSamples: [CGPoint] = (0..<samples).map { (sampleNo) in
            return attempt.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
        }
        
        let solutionSamples: [CGPoint] = (0..<samples).map { (sampleNo) in
            return spinners.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
        }
        
        /// Construct 2D binary space partitioning tree to facilitate fast 
        /// calculation of "closest point".
        let solutionTree = KDTree(values: solutionSamples)
        
        var distances: [Double] = []
        
        for attemptSample in attemptSamples {
            guard let closest = solutionTree.nearest(to: attemptSample) else {
                assert(false, "Could not find closest point to \(attemptSample)")
                continue
            }
            let distance = sqrt(attemptSample.squaredDistance(to: closest))
            distances.append(distance)
        }
        
        return distances
    }
}

import UIKit.UIColor
extension Solution {
    static let Oval: Solution = Solution(spinners: [
        Spinner(amplitude: 0.2, frequency: -1, phase: .zero, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.6, frequency: +1, phase: .pi / 2, color: UIColor.yellow.cgColor),
    ])
    
    static let Star: Solution = Solution(spinners: [
        Spinner(amplitude: 1, frequency: -1, phase: .zero, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.2, frequency: +4, phase: .zero, color: UIColor.yellow.cgColor),
    ])
    
    static let BowTie: Solution = Solution(spinners: [
        Spinner(amplitude: 0.76, frequency: -1, phase: .pi, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.58, frequency: +1, phase: .zero, color: UIColor.yellow.cgColor),
        Spinner(amplitude: 0.18, frequency: +3, phase: .zero, color: UIColor.yellow.cgColor),
    ])
    
    static let Heart: Solution = Solution(spinners: [
        Spinner(amplitude: 0.23, frequency: -3, phase: .pi, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.20, frequency: -2, phase: .pi, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.97, frequency: -1, phase: .zero, color: UIColor.yellow.cgColor),
        Spinner(amplitude: 0.20, frequency: +2, phase: .pi, color: UIColor.yellow.cgColor),
        Spinner(amplitude: 0.08, frequency: +3, phase: .zero, color: UIColor.yellow.cgColor),
    ])
}
