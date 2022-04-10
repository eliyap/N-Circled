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
    
    /// Maintains pre-gesture values to allow easy calculation of intermediate and final values.
    @State private var initialPos: CGPoint? = nil
    @State private var initialSpinner: Spinner? = nil
    
    @State private var isDragging: Bool = false
    private let dragChangeAnimation: Animation = .easeInOut(duration: 0.1)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .foregroundColor(.red)
                .frame(
                    width: size.width * Self.proportion * spinner.amplitude,
                    height: size.width * Self.proportion * spinner.amplitude
                )
                .padding(size.width * 0.5 * (1 - Self.proportion * spinner.amplitude))
            HandleView(isDragging: isDragging)
                .offset(x: size.width/2, y: size.width/2)
                .offset(
                    x: cos(spinner.phase) * spinner.amplitude * size.width * Self.proportion * 0.5,
                    y: sin(spinner.phase) * spinner.amplitude * size.width * Self.proportion * 0.5
                )
                .gesture(DragGesture().onChanged(dragDidChange).onEnded(dragDidEnd))
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func dragDidChange(with value: DragGesture.Value) -> Void {
        withAnimation(dragChangeAnimation) { isDragging = true }
        
        if (initialPos == nil) || (initialSpinner == nil) {
            initialPos = value.startLocation
            initialSpinner = spinner
            simpleSuccess()
        }
        
        guard
            let initialPos = initialPos,
            let initialSpinner = initialSpinner
        else { return }
        
        /// Scale delta up to compensate for reduced size.
        let deltaX = (value.location.x - initialPos.x) / Self.proportion
        let deltaY = (value.location.y - initialPos.y) / Self.proportion
        
        /// Collapse to unit vector.
        let normalizedX = deltaX / size.width
        let normalizedY = deltaY / size.width
        
        let updatedComplex = Complex(
            normalizedX + cos(initialSpinner.phase) * initialSpinner.amplitude,
            normalizedY + sin(initialSpinner.phase) * initialSpinner.amplitude
        )
        spinner.phase = updatedComplex.phase
        
        /// Intentionally leave magnitude alone, I found it irritating for that to change at the same time.
    }
    
    private func dragDidEnd(with value: DragGesture.Value) -> Void {
        /// Reset values.
        initialPos = nil
        initialSpinner = nil
        withAnimation(dragChangeAnimation) { isDragging = false }
    }
}

struct HandleView: View {
    
    public let isDragging: Bool
    
    var handleRadius: CGFloat {
        isDragging ? 30: 20
    }
    
    var body: some View {
        Circle()
            .frame(width: handleRadius, height: handleRadius)
            .foregroundColor(Color(uiColor: .systemBackground))
            .shadow(color: .primary.opacity(0.5), radius: 3, x: 0, y: 0)
            .offset(x: -handleRadius/2, y: -handleRadius/2)
    }
}
