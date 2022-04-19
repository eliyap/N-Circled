//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import Combine
import UIKit.UIColor

final class SpinnerHolder: ObservableObject {
    @Published var spinnerSlots: [SpinnerSlot] = [
        SpinnerSlot(.defaultNew(index: 0)),
        SpinnerSlot(nil),
        SpinnerSlot(nil),
        SpinnerSlot(nil),
    ]
    
    @Published var highlighted: Spinner? = nil
    
    @Published var gameState: GameState = .thinking
    
    init(spinnerSlots: [SpinnerSlot]) {
        self.spinnerSlots = spinnerSlots
    }
}

/// A wrapper object that allows `nil` `Optional`s to be identified in `SwiftUI.ForEach`.
internal struct SpinnerSlot: Identifiable {
    
    /// Allow private modification for automatic `Codable` synthesis.
    internal private(set) var id: UUID = .init()
    
    var spinner: Spinner?
    
    init(_ spinner: Spinner?) {
        self.spinner = spinner
    }
}

extension SpinnerSlot: Codable { /** Automatically synthesized. **/ }

extension SpinnerSlot: Equatable { /** Automatically synthesized. **/ }

internal enum GameState: Int {
    /// Player is adjusting their Spinners in the Preview.
    case thinking
    
    /// Player is watching grading animation in progress.
    case grading
    
    /// Grading animation has completed playing.
    case completed
}
