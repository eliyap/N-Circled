//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import Foundation
import Combine

/// Developer abstraction, auto-saves player's progress to disk.
internal final class PuzzleManager: ObservableObject {
    @Published public var puzzles: [Puzzle] {
        didSet {
            /// Save to disk whenever modified.
            UserDefaults.groupSuite.puzzles = puzzles
        }
    }
    
    init() {
        /// Load on app start.
        self.puzzles = UserDefaults.groupSuite.puzzles
    }
}
