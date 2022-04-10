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
            HStack {
                ForEach($spinnerHolder.spinners) { $spinner in
                    SpinnerThumbnailView(spinner: $spinner)
                }
            }
                .padding(SpinnerThumbnailView.shadowRadius)
        }
    }
}

struct SpinnerThumbnailView: View {
    
    @Binding public var spinner: Spinner
    
    @State private var isEditing: Bool = false
    
    private let cornerRadius: CGFloat = 7
    public static let shadowRadius: CGFloat = 7
    
    var body: some View {
        Text("s")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(Color(uiColor: .secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: Self.shadowRadius / 2, x: 0, y: 0)
            })
            .onTapGesture(perform: {
                isEditing = true
            })
            .fullScreenCover(isPresented: $isEditing, content: {
                SpinnerEditView.init(spinner: $spinner)
            })
    }
}
