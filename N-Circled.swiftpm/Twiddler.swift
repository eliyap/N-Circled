//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI
import ComplexModule

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

struct SpinnerEditView: View {
    
    @Binding public var bound: Spinner
    @State public var modified: Spinner
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    init(spinner: Binding<Spinner>) {
        self._bound = spinner
        self._modified = .init(initialValue: spinner.wrappedValue)
    }
    
    var body: some View {
        VStack {
            HStack {
                CancelButton
                Spacer()
                DoneButton
            }
            
            Stepper(value: $modified.frequency, in: (-5)...(+5), step: 1, label: {
                Text(Image(systemName: "tornado"))
                + Text(" ")
                + Text("Do \(modified.frequency) \(modified.frequency == 1 ? "rotation" : "rotations")")
            })
                .padding(buttonPadding)
                .background(content: {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(buttonBackground)
                })
            
            VStack(alignment: .leading) {
                Text(Image(systemName: "person.fill.and.arrow.left.and.arrow.right"))
                + Text(" ")
                + Text("Size:")
                + Text(" ")
                + Text(String(format: "%.2f", modified.amplitude))
                
                Slider(value: $modified.amplitude, in: 0...1, label: {
                    Text("Amplitude")
                }, minimumValueLabel: {
                    Text("0")
                }, maximumValueLabel: {
                    Text("1")
                }, onEditingChanged: { (changed: Bool) in
                    
                })
            }
                .padding(buttonPadding)
                .background(content: {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(buttonBackground)
                })
            
            GeometryReader { geo in
                AngleAdjustmentView(size: geo.size, spinner: $modified)
            }
                .aspectRatio(1, contentMode: .fit)
                .border(.red)
            
            Spacer()
        }
            .padding(buttonPadding * 2)
    }
    
    let buttonPadding: CGFloat = 7.5
    let cornerRadius: CGFloat = 7
    var buttonBackground: Color {
        colorScheme == .light
            ? .gray.opacity(0.07)
            : .gray.opacity(0.20)
    }
    var buttonStroke: Color {
        colorScheme == .light
            ? .gray.opacity(0.25)
            : .gray.opacity(0.3)
    }
    private var CancelButton: some View {
        Button(action: {
            /// Discards changes on `modified`.
            
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel") + Text(" ") + Text(Image(systemName: "xmark"))
        })
            .padding(buttonPadding)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(buttonBackground)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(buttonStroke)
            })
    }
    
    private var DoneButton: some View {
        Button(action: {
            /// Commit changes.
            bound = modified
            
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done") + Text(" ") + Text(Image(systemName: "checkmark"))
        })
            .padding(buttonPadding)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(buttonBackground)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(buttonStroke)
            })
    }
}

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
