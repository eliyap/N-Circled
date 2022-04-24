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
    public var playerMessage: String
    
    public static let scoreThreshold = 0.8
    internal var displayName: String {
        var str = name
        if unlocked == false {
            str += " – 🔒"
        }
        return str
    }
}

extension Puzzle: Codable { /** Automatically synthesized. **/ }

extension Puzzle: Identifiable { /** Automatically synthesized. **/ }

extension Puzzle: Equatable { /** Automatically synthesized. **/ }

extension Puzzle {
    /// Default puzzle state when players first open the app.
    internal static let initialSet: [Puzzle] = [.Oval, .Star, .BowTie, .Heart]
    
    internal static let Oval = Puzzle(
        name: "Puzzle 1 🥚",
        solution: Solution.Oval,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
        ],
        unlocked: true,
        playerMessage: ""
    )
    
    internal static let Star = Puzzle(
        name: "Puzzle 2 ⭐️",
        solution: Solution.Star,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false,
        playerMessage: ""
    )
    
    internal static let BowTie = Puzzle(
        name: "Puzzle 3 🎀",
        solution: Solution.BowTie,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false,
        playerMessage: ""
    )
    
    internal static let Heart = Puzzle(
        name: "Puzzle 4 ❤️",
        solution: .Heart,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false,
        playerMessage: ""
    )
}
