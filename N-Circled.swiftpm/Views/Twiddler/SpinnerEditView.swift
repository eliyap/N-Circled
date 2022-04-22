//
//  SpinnerEditView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI

struct SpinnerEditView: View {
    
    @Binding public var bound: SpinnerSlot
    @State public var modified: Spinner
    @State private var showDeleteAlert: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    init(spinnerSlot: Binding<SpinnerSlot>, spinnerIndex: Int?) {
        self._bound = spinnerSlot
        
        /// Resolve optional.
        let index: Int = {
            if let spinnerIndex = spinnerIndex {
                return spinnerIndex
            } else {
                assert(false, "Could not find spinner index")
                return 0
            }
        }()
        
        /// Create new spinner if one is not available.
        self._modified = .init(initialValue: spinnerSlot.wrappedValue.spinner ?? Spinner.defaultNew(index: index))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Spinner")
                .font(.title.bold())
                .padding(.bottom, SpinnerEditView.buttonPadding)
            HStack {
                CancelButton
                Spacer()
                DoneButton
            }
            
            FrequencyComponent(modified: $modified)
            
            AmplitudeSliderView(spinner: $modified)
                .padding(SpinnerEditView.buttonPadding)
                .modifier(TwiddleBackground())
            
            DialComponent(modified: $modified)
            
            Spacer()
            
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }, label: {
                Text("Delete Spinner")
            })
                .alert("Delete Spinner?", isPresented: $showDeleteAlert, actions: {
                    Button(role: .destructive, action: {
                        bound.spinner = nil
                        presentationMode.wrappedValue.dismiss()
                    }, label: { Text("Delete" )})
                })
                .padding(.vertical, SpinnerEditView.buttonPadding)
                .padding(SpinnerEditView.buttonPadding)
                .frame(maxWidth: .infinity)
                .modifier(TwiddleBackground())
        }
            .padding(SpinnerEditView.buttonPadding * 2)
    }
    
    public static let buttonPadding: CGFloat = 7.5
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
            .padding(SpinnerEditView.buttonPadding)
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
            bound.spinner = modified
            
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done") + Text(" ") + Text(Image(systemName: "checkmark"))
        })
            .padding(SpinnerEditView.buttonPadding)
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(buttonBackground)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(buttonStroke)
            })
    }
}

fileprivate struct FrequencyComponent: View {
    
    @Binding private var modified: Spinner
    @State var spinCount: Int
    @State var clockwise: Bool
    
    public init(modified: Binding<Spinner>) {
        self._modified = modified
        self._spinCount = .init(initialValue: abs(modified.wrappedValue.frequency))
        self._clockwise = .init(initialValue: modified.wrappedValue.frequency >= 0)
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text(Image(systemName: "tornado"))
                + Text(" ")
                + Text("Rotations (Frequency)")
                
                Stepper(value: $spinCount, in: 0...5, step: 1, label: {
                    Text("\(spinCount) rotation\(spinCount == 1 ? "" : "s")")
                })
                
                HStack {
                    Text(Image(systemName: clockwise ? "arrow.clockwise" : "arrow.counterclockwise"))
                    + Text(" ")
                    + Text(clockwise ? "Clockwise" : "Counter-Clockwise")
                    
                    Spacer()
                    Button(action: {
                        clockwise.toggle()
                    }, label: {
                        Text("Switch")
                    })
                }
            }
                .padding(SpinnerEditView.buttonPadding)
                .modifier(TwiddleBackground())
                .onChange(of: spinCount, perform: { newCount in
                    modified.frequency = (clockwise ? +1 : -1) * newCount
                })
                .onChange(of: clockwise, perform: { newDir in
                    modified.frequency = (newDir ? +1 : -1) * spinCount
                })
        }
    }
    
    private func direction(of spin: Int) -> String {
        var str = "\(abs(modified.frequency))"
        
        switch spin {
        case let x where x < 0:
            str += " counter-clockwise"
        case let x where x > 0:
            str += " clockwise"
        default:
            break
        }
        
        str += " "
        str += "rotation"
        if abs(modified.frequency) != 1 {
            str += "s"
        }
        
        return str
    }
}

fileprivate struct DialComponent: View {
    
    @Binding public var modified: Spinner
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top )  {
                VStack(alignment: .leading, spacing: SpinnerEditView.buttonPadding) {
                    (Text(Image(systemName: "dial.min.fill")) + Text(" ") + Text("Circle Start Angle (Phase)"))
                    (Text(Image(systemName: "hand.draw.fill")) + Text(" ") + Text("Drag to Adjust"))
                }
                Spacer()
                Text("\(modified.phaseInDegrees)°")
            }
                .padding(SpinnerEditView.buttonPadding)
            
            GeometryReader { geo in
                DialView(size: geo.size, spinner: $modified)
            }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: 250)
        }
            .modifier(TwiddleBackground())
    }
}

struct TwiddleBackground: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let buttonPadding: CGFloat = SpinnerEditView.buttonPadding
    let cornerRadius: CGFloat = 7
    var buttonBackground: Color {
        colorScheme == .light
            ? .gray.opacity(0.07)
            : .gray.opacity(0.20)
    }
    
    func body(content: Content) -> some View {
        content
            .background(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(buttonBackground)
            })
    }
}
