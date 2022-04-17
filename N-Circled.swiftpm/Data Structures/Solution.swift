//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import CoreGraphics
import KDTree

struct Scorer {
    let base: Double
    let maxExponent: Double
    let scalar: Double
    
    init(
        base: Double = 2.0,
        maxExponent: Double = 2.0,
        scalar: Double = 10.0
    ) {
        self.base = base
        self.maxExponent = maxExponent
        self.scalar = scalar
    }
    
    /** Scores a distance.
     *  Scoring goals:
     *  - higher is better, better is higher
     *  - should always be positive
     *  - bounded values (has a minimum and maximum)
     * 
     *  Exponents satisfy all these criteria.
     */
    func score(distance: Double) -> Double { 
        assert(distance >= 0, "Received negative distance: \(distance)")
        
        return pow(base, maxExponent - (scalar * distance))
    }

    func normalizedScore(distance: Double) -> Double {
        return score(distance: distance) / maxScore
    }

    var maxScore: Double {
        return pow(base, maxExponent)
    }
}

struct Solution {
    let spinners: [Spinner]
    
    func score(attempt: [Spinner], samples: Int) -> Double {
        
        let distances = distances(attempt: attempt, samples: samples)
        
        let scorer = Scorer()
        var score: Double = .zero
        
        for distance in distances {
            score += scorer.normalizedScore(distance: distance)
        }
        
        /// Normalize score.
        score /= Double(samples)
        
        return score
    }
    
    static func score(upTo index: Int, of distances: [Double]) -> Double {
        guard 0 <= index && index <= distances.count else {
            assert(false, "Invalid index \(index) ")
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
    
    func distances(attempt: [Spinner], samples: Int) -> [Double] {
        
        let attemptSamples: [CGPoint] = (0..<samples).map { (sampleNo) in
            return attempt.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
        }
        
        let solutionSamples: [CGPoint] = (0..<samples).map { (sampleNo) in
            return spinners.vectorFor(proportion: CGFloat(sampleNo) / CGFloat(samples))
        }
        let solutionTree = KDTree(values: solutionSamples)
        
        var distances: [Double] = []
        
        for attemptSample in attemptSamples {
            guard let closest = solutionTree.nearest(to: attemptSample) else {
                assert(false, "Could not find closest point to \(attemptSample)")
                continue
            }
            let distance = attemptSample.squaredDistance(to: closest)
            distances.append(distance)
        }
        
        return distances
    }
}

import UIKit.UIColor
extension Solution {
    static let Oval: Solution = Solution(spinners: [
        Spinner(amplitude: 0.2, frequency: -1, phase: .pi / 10, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.6, frequency: +1, phase: .pi / 17, color: UIColor.yellow.cgColor),
    ])
}
