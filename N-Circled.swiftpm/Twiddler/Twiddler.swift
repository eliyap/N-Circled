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
            
            AmplitudeSliderView(spinner: $modified)
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
