//
//  DoodleView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI
import UIKit

struct DoodleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DoodleViewController
    
    func makeUIViewController(context: Context) -> DoodleViewController {
        let vc: UIViewControllerType = .init()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DoodleViewController, context: Context) {
        /// Nothing.
    }
    
    
}

final class DoodleViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
