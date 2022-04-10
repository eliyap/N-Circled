//
//  AngleAdjustmentView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI
import ComplexModule

/// `size` assumed to be a square.
struct AngleAdjustmentView: View {
    
    public let size: CGSize
    @Binding public var spinner: Spinner
    
    /// Fraction of available width consumed.
    private static let proportion: CGFloat = 0.75
    private static let remainder: CGFloat = 1 - proportion
    
    @State private var initialPos: CGPoint? = nil
    @State private var initialSpinner: Spinner? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .foregroundColor(.red)
                .frame(
                    width: size.width * Self.proportion * spinner.amplitude,
                    height: size.width * Self.proportion * spinner.amplitude
                )
                .padding(size.width * 0.5 * (Self.remainder + Self.proportion * (1 - spinner.amplitude)))
            Handle
                .offset(x: -handleRadius/2, y: -handleRadius/2)
                .offset(x: size.width/2, y: size.width/2)
                .offset(
                    x: cos(spinner.phase) * spinner.amplitude * size.width * Self.proportion * 0.5,
                    y: sin(spinner.phase) * spinner.amplitude * size.width * Self.proportion * 0.5
                )
                .gesture(DragGesture().onChanged(dragDidChange).onEnded(dragDidEnd))
        }
    }
    
    private func dragDidChange(with value: DragGesture.Value) -> Void {
        if (initialPos == nil) || (initialSpinner == nil) {
            initialPos = value.startLocation
            initialSpinner = spinner
        }
        
        guard
            let initialPos = initialPos,
            let initialSpinner = initialSpinner
        else { return }
        
        let deltaX = value.location.x - initialPos.x
        let deltaY = value.location.y - initialPos.y
        let normalizedX = deltaX / size.width
        let normalizedY = deltaY / size.width
        let updatedComplex = Complex(
            normalizedX + cos(initialSpinner.phase) * initialSpinner.amplitude,
            normalizedY + sin(initialSpinner.phase) * initialSpinner.amplitude
        )
        spinner.phase = updatedComplex.phase
        spinner.amplitude = min(max(updatedComplex.magnitude, 0), 1)
    }
    
    private func dragDidEnd(with value: DragGesture.Value) -> Void {
        /// Reset values.
        initialPos = nil
        initialSpinner = nil
    }
    
    private let handleRadius: CGFloat = 20
    private var Handle: some View {
        Circle()
            .frame(width: handleRadius, height: handleRadius)
            .foregroundColor(Color(uiColor: .systemBackground))
            .shadow(color: .primary.opacity(0.5), radius: 3, x: 0, y: 0)
    }
}
