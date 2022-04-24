//
//  GameState.swift
//  
//
//  Created by Secret Asian Man Dev on 24/4/22.
//

import Foundation

internal enum GameState: Int {
    /// Player is adjusting their Spinners in the Preview.
    case thinking
    
    /// Player is watching grading animation in progress.
    case grading
    
    /// Grading animation has completed, show game outcome.
    case won
    case lost
}
