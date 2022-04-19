//
//  TwiddlerCollectionView.swift
//  
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI

struct TwiddlerCollectionView: View {
    
    @ObservedObject public var spinnerHolder: SpinnerHolder
    
    public static let viewHeight: CGFloat = 100
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach($spinnerHolder.spinnerSlots) { $spinnerSlot in
                    SpinnerThumbnailView(spinnerSlot: $spinnerSlot, spinnerIndex: spinnerHolder.spinnerSlots.firstIndex(of: spinnerSlot))
                        .onTapGesture(perform: {
                            spinnerHolder.highlighted = spinnerSlot.spinner
                        })
                }
            }
                .padding(SpinnerThumbnailView.shadowRadius)
        }
            /// Don't allow user interaction while grading.
            .disabled(spinnerHolder.gameState != .thinking)
    }
}

struct SpinnerThumbnailView: View {
    
    @Binding public var spinnerSlot: SpinnerSlot
    public let spinnerIndex: Int?
    
    @State private var isEditing: Bool = false
    
    private let cornerRadius: CGFloat = 7
    public static let shadowRadius: CGFloat = 7
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("s")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button(action: { isEditing = true }, label: {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(5)
                    .contentShape(Rectangle())
            })
        }
            .padding(3)
            .frame(width: TwiddlerCollectionView.viewHeight, height: TwiddlerCollectionView.viewHeight)
            .aspectRatio(1, contentMode: .fit)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(Color(uiColor: .secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: Self.shadowRadius / 2, x: 0, y: 0)
            })
            .onTapGesture(count: 2, perform: { isEditing = true })
            .fullScreenCover(isPresented: $isEditing, content: {
                SpinnerEditView.init(spinnerSlot: $spinnerSlot, spinnerIndex: spinnerIndex)
            })
    }
}
