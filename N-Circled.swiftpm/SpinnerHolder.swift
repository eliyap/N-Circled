//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import SwiftUI

final class SpinnerHolder: ObservableObject {
    
    @Published var spinners: [Spinner] = []
    
    @Published var points: [CGPoint] = []
    
    init() {
        
    }
}
