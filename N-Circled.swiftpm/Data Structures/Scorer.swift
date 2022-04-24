//
//  Scorer.swift
//  
//
//  Created by Secret Asian Man Dev on 18/4/22.
//

import Foundation

/// Transforms distance between the player's attempt and the intended
/// solution into a percentage score.
struct Scorer {
    
    /// Parameters for the score calculation.
    /// Tweaking these affects the "harshness" of the scoring.
    public let base: Double
    public let scalar: Double
    
    init(
        base: Double = 2.0,
        scalar: Double = 5.0
    ) {
        self.base = base
        self.scalar = scalar
    }
    
    /** Scores a distance.
     *  Scoring goals:
     *  - higher is better, better is higher (score gradient is always positive)
     *  - score falls within `[0, 1]` interval.
     *
     *  Exponents satisfy all these criteria (provided distance is non-negative).
     */
    func score(distance: Double) -> Double {
        assert(distance >= 0, "Received negative distance: \(distance)")
        
        return pow(base, -scalar * distance)
    }
    
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
            score += scorer.score(distance: distance)
        }
        
        /// Normalize score.
        score /= Double(distances.count)
        
        return score
    }
}
