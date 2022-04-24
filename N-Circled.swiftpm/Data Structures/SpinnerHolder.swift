//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import Combine
import UIKit.UIColor

/// Represents ephemeral gamestate not captured in `Puzzle`.
final internal class SpinnerHolder: ObservableObject {
    
    /// Player's current spinners.
    @Published var spinnerSlots: [SpinnerSlot]
    
    /// Game state controls what views are shown.
    @Published var gameState: GameState = .thinking
    
    init(spinnerSlots: [SpinnerSlot]) {
        self.spinnerSlots = spinnerSlots
    }
}
