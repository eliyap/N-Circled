//
//  Puzzle.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import Foundation

struct Puzzle {
    public var name: String
    public let solution: Solution
    public var attempt: [SpinnerSlot]
    public var unlocked: Bool
}

extension Puzzle: Codable { }
