//
//  PuzzleStorage.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import Foundation

extension UserDefaults {
    static var groupSuite = UserDefaults(suiteName: "group.com.wwdc.ncircle")!

    var puzzles: [Puzzle] {
        get {
            guard let data = object(forKey: #function) as? Data else {
                Swift.debugPrint("No data in \(#function), initializing new store.")
                return Puzzle.initialSet
            }
            guard let loaded = try? JSONDecoder().decode([Puzzle].self, from: data) else {
                Swift.debugPrint("Error: Could not decode data in \(#function)")
                return Puzzle.initialSet
            }
            return loaded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                assert(false, "Could not encode!")
                return
            }
            set(encoded, forKey: #function)
        }
    }
}
