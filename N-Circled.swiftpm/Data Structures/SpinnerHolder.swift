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
        SpinnerSlot(.defaultNew),
        SpinnerSlot(nil),
        SpinnerSlot(nil),
        SpinnerSlot(nil),
    ]
    
    @Published var highlighted: Spinner? = nil
    
    @Published var isGrading: Bool = false
}

/// A wrapper object that allows `nil` `Optional`s to be identified in `SwiftUI.ForEach`.
internal struct SpinnerSlot: Identifiable {
    public let id: UUID = .init()
    
    var spinner: Spinner?
    
    init(_ spinner: Spinner?) {
        self.spinner = spinner
    }
}
