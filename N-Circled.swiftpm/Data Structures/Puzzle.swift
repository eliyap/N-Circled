//
//  Puzzle.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import Foundation

struct Puzzle {
    internal private(set) var id: UUID = .init()
    public var name: String
    public let solution: Solution
    public var attempt: [SpinnerSlot]
    public var unlocked: Bool
    
    public static let scoreThreshold = 0.8
}

extension Puzzle: Codable { /** Automatically synthesized. **/ }

extension Puzzle: Identifiable { /** Automatically synthesized. **/ }

extension Puzzle {
    /// Default puzzle state when players first open the app.
    internal static let initialSet: [Puzzle] = [.Oval, .Star, .BowTie, .Heart]
    
    internal static let Oval = Puzzle(
        name: "Puzzle 1 🥚",
        solution: Solution.Oval,
        attempt: [
            SpinnerSlot(.defaultNew(index: 0)),
            SpinnerSlot(nil),
        ],
        unlocked: true
    )
    
    internal static let Star = Puzzle(
        name: "Puzzle 2 ⭐️",
        solution: Solution.Star,
        attempt: [
            SpinnerSlot(.defaultNew(index: 0)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false
    )
    
    internal static let BowTie = Puzzle(
        name: "Puzzle 3 🎀",
        solution: Solution.BowTie,
        attempt: [
            SpinnerSlot(.defaultNew(index: 0)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false
    )
    
    internal static let Heart = Puzzle(
        name: "Puzzle 4 ❤️",
        solution: .Heart,
        attempt: [
            SpinnerSlot(.defaultNew(index: 0)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false
    )
}
