//
//  AmplitudeSliderView.swift
//  
//
//  Created by Secret Asian Man Dev on 10/4/22.
//

import SwiftUI

struct AmplitudeSliderView: View {

    @Binding public var spinner: Spinner

    var body: some View {
        VStack(alignment: .leading) {
                Text(Image(systemName: "person.fill.and.arrow.left.and.arrow.right"))
                + Text(" ")
                + Text("Size:")
                + Text(" ")
                + Text(String(format: "%.2f", spinner.amplitude))
                
                Slider(value: $spinner.amplitude, in: 0...1, label: {
                    Text("Amplitude")
                }, minimumValueLabel: {
                    Text("0")
                }, maximumValueLabel: {
                    Text("1")
                }, onEditingChanged: { (changed: Bool) in
                    
                })
            }
    }
}
