//
//  Scorer.swift
//  
//
//  Created by Secret Asian Man Dev on 18/4/22.
//

import Foundation

struct Scorer {
    let base: Double
    let maxExponent: Double
    let scalar: Double
    
    init(
        base: Double = 2.0,
        maxExponent: Double = 2.0,
        scalar: Double = 3.0
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
