//
//  ConfettiView.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import SwiftUI

struct ConfettiView: UIViewRepresentable {
    
    public let size: CGSize
    
    func makeUIView(context: Context) -> UIConfettiView {
        let view = UIConfettiView()
        return view
    }
    
    func updateUIView(_ uiView: UIConfettiView, context: Context) {
        /// Nothing.
    }
}
