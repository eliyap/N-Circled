//
//  DoodleView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI
import UIKit
import PencilKit

struct DoodleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDoodleViewController
    
    func makeUIViewController(context: Context) -> UIDoodleViewController {
        let vc: UIViewControllerType = .init()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIDoodleViewController, context: Context) {
        /// Nothing.
    }
}

final class UIDoodleViewController: UIViewController {
    
    private let doodleView: UIDoodleView
    
    init() {
        self.doodleView = .init()
        super.init(nibName: nil, bundle: nil)
        
        self.view = doodleView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class UIDoodleView: PKCanvasView {
    init() {
        super.init(frame: .zero)
        
        /// Permit finger input by default.
        self.drawingPolicy = .anyInput
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
