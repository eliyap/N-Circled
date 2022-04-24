//
//  SpinnerSlot.swift
//  
//
//  Created by Secret Asian Man Dev on 24/4/22.
//

import Foundation

/// A wrapper object that allows `nil` `Optional`s to be identified in `SwiftUI.ForEach`.
internal struct SpinnerSlot: Identifiable {
    
    /// Allow private modification for automatic `Codable` synthesis.
    internal private(set) var id: UUID = .init()
    
    public var spinner: Spinner?
    
    init(_ spinner: Spinner?) {
        self.spinner = spinner
    }
}

extension SpinnerSlot: Codable { /** Automatically synthesized. **/ }

extension SpinnerSlot: Equatable { /** Automatically synthesized. **/ }
