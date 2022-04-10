//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI

struct TwiddlerCollectionView: View {
    
    @ObservedObject public var spinnerHolder: SpinnerHolder
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: .zero) {
                ForEach($spinnerHolder.spinners) { $spinner in
                    SpinnerTwiddlerView(spinner: $spinner)
                }
            }
        }
    }
}

struct SpinnerTwiddlerView: View {
    
    @Binding public var spinner: Spinner
    
    var body: some View {
        Text("")
    }
}
