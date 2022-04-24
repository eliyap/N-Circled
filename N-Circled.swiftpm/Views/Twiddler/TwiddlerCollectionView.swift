//
//  TwiddlerCollectionView.swift
//  
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI

struct TwiddlerCollectionView: View {
    
    @ObservedObject public var spinnerHolder: SpinnerHolder
    
    public static let viewWidth: CGFloat = 100
    public static let spacing: CGFloat = 8
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                LazyVGrid(columns: [
                    GridItem(.fixed(TwiddlerCollectionView.viewWidth), spacing: TwiddlerCollectionView.spacing),
                    GridItem(.fixed(TwiddlerCollectionView.viewWidth), spacing: TwiddlerCollectionView.spacing),
                ]) {
                    ForEach($spinnerHolder.spinnerSlots) { $spinnerSlot in
                        SpinnerThumbnailView(spinnerSlot: $spinnerSlot, spinnerIndex: spinnerHolder.spinnerSlots.firstIndex(of: spinnerSlot))
                    }
                }
            }
        }
            .frame(width: TwiddlerCollectionView.viewWidth * 2 + TwiddlerCollectionView.spacing)
            .padding(TwiddlerCollectionView.spacing)
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
            if let spinner = spinnerSlot.spinner {
                Circle()
                    .fill(spinner.gradient)
                    .rotationEffect(Angle(radians: spinner.phase))
                    .scaleEffect(spinner.amplitude)
            } else {
                ZStack(alignment: .center) {
                    Image(systemName: "plus")
                    Color.clear
                }
            }
            Image(systemName: "square.and.pencil")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(5)
                .contentShape(Rectangle())
                .foregroundColor(.accentColor)
        }
            .padding(3)
            .frame(width: TwiddlerCollectionView.viewWidth, height: TwiddlerCollectionView.viewWidth)
            .aspectRatio(1, contentMode: .fit)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(Color(uiColor: .secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: Self.shadowRadius / 2, x: 0, y: 0)
            })
            .onTapGesture(perform: { isEditing = true })
            .contentShape(Rectangle())
            .fullScreenCover(isPresented: $isEditing, content: {
                SpinnerEditView.init(spinnerSlot: $spinnerSlot, spinnerIndex: spinnerIndex)
            })
    }
}

fileprivate extension Spinner {
    var gradient: SwiftUI.AngularGradient {
        var colors = [
            Color(uiColor: .systemBackground),
            Color(uiColor: color.uiColor),
        ]
        if frequency < 0 {
            colors.reverse()
        }
        return AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center
        )
    }
}
