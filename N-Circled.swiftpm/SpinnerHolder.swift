//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import Combine

final class SpinnerHolder: ObservableObject {
    @Published var spinners: [Spinner] = [
        Spinner(amplitude: 0.5, frequency: +1, phase: .pi / 10),
        Spinner(amplitude: 0.4, frequency: +2, phase: .pi / 17),
        Spinner(amplitude: 0.3, frequency: +3, phase: .pi / 20),
        Spinner(amplitude: 0.2, frequency: +4, phase: .pi / 6),
        Spinner(amplitude: 0.1, frequency: +5, phase: .pi / 4),
    ]
}
