//
//  TwiddlerCollectionView.swift
//  
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
                    SpinnerThumbnailView(spinner: $spinner)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .border(.red)
                }
            }
        }
    }
}

struct SpinnerThumbnailView: View {
    
    @Binding public var spinner: Spinner
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        Text("s")
            .onTapGesture(perform: {
                isEditing = true
            })
            .fullScreenCover(isPresented: $isEditing, content: {
                SpinnerEditView.init(spinner: $spinner)
            })
    }
}
