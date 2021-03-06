//
//  Puzzle.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import Foundation

struct Puzzle {
    
    /// Makes `SwiftUI.ForEach` usage easier.
    internal private(set) var id: UUID = .init()
    
    public var name: String
    
    public let solution: Solution
    
    /// The player's input, compared to the solution to determine "correctness".
    public var attempt: [SpinnerSlot]
    
    /// Whether the puzzle is available to try.
    public var unlocked: Bool
    
    /// Hints and instructions to get the player started.
    public var playerMessage: String
    
    /// How "close" players must score to the intended solution.
    public static let scoreThreshold = 0.8
    
    /// Shows name and lock status to players.
    internal var displayName: String {
        var str = name
        if unlocked == false {
            str += " â đ"
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
        name: "Puzzle 1 đĨ",
        solution: Solution.Oval,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
        ],
        unlocked: true,
        playerMessage: """
            đ Welcome!
            
            đĢĨ In N-Circle, your goal is to match the dotted line
            
            đ Adjust your spinners to get closer
            
            âļī¸ When ready, hit Play!
            
            âšī¸ Hint: spin in opposite directions
            """
    )
    
    internal static let Star = Puzzle(
        name: "Puzzle 2 â­ī¸",
        solution: Solution.Star,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false,
        playerMessage: """
            đĢ It's hard to believe, but circles can make spiky shapes!
            
            âšī¸ Hint: Opposite directions, different frequencies
            """
    )
    
    internal static let BowTie = Puzzle(
        name: "Puzzle 3 đ",
        solution: Solution.BowTie,
        attempt: [
            SpinnerSlot(Spinner(amplitude: 0.66, frequency: -1, phase: .zero, color: SpinnerColor(rawValue: 0)!)),
            SpinnerSlot(Spinner(amplitude: 0.33, frequency: -3, phase: .zero, color: SpinnerColor(rawValue: 1)!)),
            SpinnerSlot(nil),
            SpinnerSlot(nil),
        ],
        unlocked: false,
        playerMessage: """
            đĒ Let's draw a harder shape!
            
            âšī¸ Hint: Try frequencies two apart
            """
    )
    
    internal static let Heart = Puzzle(
        name: "Puzzle 4 â¤ī¸",
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
        playerMessage: """
            đ Don't give up!
            
            âšī¸ Hint: You'll need all spinners but one!
            """
    )
}
