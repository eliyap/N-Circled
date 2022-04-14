//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import Combine
import UIKit.UIColor

final class SpinnerHolder: ObservableObject {
    @Published var spinners: [Spinner] = [
        Spinner(amplitude: 0.2, frequency: -1, phase: .pi / 10, color: UIColor.green.cgColor),
        Spinner(amplitude: 0.6, frequency: +1, phase: .pi / 17, color: UIColor.yellow.cgColor),
        Spinner(amplitude: 0.3, frequency: +3, phase: .pi / 20, color: UIColor.orange.cgColor),
        Spinner(amplitude: 0.2, frequency: +4, phase: .pi / 6, color: UIColor.purple.cgColor),
        Spinner(amplitude: 0.1, frequency: +5, phase: .pi / 4, color: UIColor.blue.cgColor),
    ]
    
    @Published var highlighted: Spinner? = nil
}
