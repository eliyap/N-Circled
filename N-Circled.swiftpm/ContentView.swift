import SwiftUI

struct ContentView: View {
    
    @StateObject private var puzzleManager: PuzzleManager = .init()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: {
                    OldPuzzleView(solution: .Oval)
                }, label: {
                    Text("Puzzle 1 🥚")
                })
                NavigationLink(destination: {
                    OldPuzzleView(solution: .Star)
                }, label: {
                    Text("Puzzle 2 ⭐️")
                })
                NavigationLink(destination: {
                    OldPuzzleView(solution: .BowTie)
                }, label: {
                    Text("Puzzle 3 🎀")
                })
                NavigationLink(destination: {
                    OldPuzzleView(solution: .Heart)
                }, label: {
                    Text("Puzzle 4 ❤️")
                })
            }
        }
    }
}

struct OldPuzzleView: View {
    
    public let solution: Solution
    @StateObject private var spinnerHolder: SpinnerHolder = .init()
    
    public static let transitionDuration: TimeInterval = 0.5
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, WWDC!")
                Text("\(spinnerHolder.spinnerSlots.count)")
                ActionButton
            }
            GeometryReader { geo in
                if spinnerHolder.gameState == .thinking {
                    CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
                        .border(.purple)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    GradingView.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution, gradingCompletionCallback: didFinishGrading(didWin:))
                        .border(.red)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
    
    private func didFinishGrading(didWin: Bool) -> Void {
        spinnerHolder.gameState = .completed
    }
    
    @ViewBuilder
    private var ActionButton: some View {
        switch spinnerHolder.gameState {
        case .thinking, .grading:
            Button(action: {
                withAnimation(.easeInOut(duration: OldPuzzleView.transitionDuration)) {
                    spinnerHolder.gameState = .grading
                }
            }, label: {
                Text("Play!")
            })
                /// Don't allow user interaction while grading.
                .disabled(spinnerHolder.gameState == .grading)
        case .completed:
            Button(action: {
                withAnimation(.easeInOut(duration: OldPuzzleView.transitionDuration)) {
                    spinnerHolder.gameState = .thinking
                }
            }, label: {
                Text("Try Again")
            })
        }
    }
}
