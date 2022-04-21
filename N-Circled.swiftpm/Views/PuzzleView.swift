//
//  PuzzleView.swift
//  
//
//  Created by Secret Asian Man Dev on 19/4/22.
//

import SwiftUI

struct PuzzleView: View {
    
    @StateObject private var spinnerHolder: SpinnerHolder
    
    public static let transitionDuration: TimeInterval = 0.5
    @Binding private var puzzle: Puzzle
    @State private var showConfetti: Bool = false
    
    private let didWinPuzzle: (Puzzle) -> Void
    
    /// Wraps bound puzzle state with additional gamestate.
    init(puzzle: Binding<Puzzle>, didWinPuzzle: @escaping (Puzzle) -> Void) {
        self._spinnerHolder = .init(wrappedValue: SpinnerHolder(spinnerSlots: puzzle.wrappedValue.attempt))
        self._puzzle = puzzle
        self.didWinPuzzle = didWinPuzzle
    }
    
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    if spinnerHolder.gameState == .thinking {
                        CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder, solution: puzzle.solution)
                            .border(.purple)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        GradingView.init(size: geo.size, spinnerHolder: spinnerHolder, solution: puzzle.solution, gradingCompletionCallback: didFinishGrading(didWin:))
                            .border(.red)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                    .frame(height: TwiddlerCollectionView.viewHeight)
            }
            if showConfetti {
                GeometryReader { geo in
                    ConfettiView(size: geo.size)
                }
            }
        }
            .navigationTitle(puzzle.name)
            .navigationBarTitleDisplayMode(.inline)
            /// Pass any changes upwards.
            .onReceive(spinnerHolder.$spinnerSlots, perform: { spinnerSlots in
                puzzle.attempt = spinnerSlots
            })
            .toolbar(content: {
                ActionButton
            })
    }
    
    /// Callback for when the grading animation has completed.
    private func didFinishGrading(didWin: Bool) -> Void {
        spinnerHolder.gameState = .completed
        showConfetti = didWin
        if didWin {
            didWinPuzzle(puzzle)
        }
    }
    
    @ViewBuilder
    private var ActionButton: some View {
        switch spinnerHolder.gameState {
        case .thinking, .grading:
            Button(action: {
                withAnimation(.easeInOut(duration: PuzzleView.transitionDuration)) {
                    spinnerHolder.gameState = .grading
                }
            }, label: {
                Text("▶️ Play!")
            })
                /// Don't allow user interaction while grading.
                .disabled(spinnerHolder.gameState == .grading)
        case .completed:
            Button(action: {
                withAnimation(.easeInOut(duration: PuzzleView.transitionDuration)) {
                    spinnerHolder.gameState = .thinking
                }
            }, label: {
                Text("🔄 Try Again")
            })
        }
    }
}
