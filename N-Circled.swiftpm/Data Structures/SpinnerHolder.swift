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
        SpinnerSlot(Spinner(amplitude: 0.23, frequency: -3, phase: .pi, color: UIColor.green.cgColor)),
        SpinnerSlot(Spinner(amplitude: 0.20, frequency: -2, phase: .pi, color: UIColor.green.cgColor)),
        SpinnerSlot(Spinner(amplitude: 0.97, frequency: -1, phase: .zero, color: UIColor.yellow.cgColor)),
        SpinnerSlot(Spinner(amplitude: 0.20, frequency: +2, phase: .pi, color: UIColor.yellow.cgColor)),
        SpinnerSlot(Spinner(amplitude: 0.08, frequency: +3, phase: .zero, color: UIColor.yellow.cgColor)),
    ]
    
    @Published var highlighted: Spinner? = nil
    
    @Published var isGrading: Bool = false
}

internal struct SpinnerSlot: Identifiable {
    public let id: UUID = .init()
    
    var spinner: Spinner
    
    init(_ spinner: Spinner) {
        self.spinner = spinner
    }
}
