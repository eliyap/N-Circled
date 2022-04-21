import SwiftUI

struct ContentView: View {
    
    @StateObject private var puzzleManager: PuzzleManager = .init()
    
    #if DEBUG
    @State private var didResetPuzzles: Bool = false
    @State private var didUnlockPuzzles: Bool = false
    #endif
    
    var body: some View {
        NavigationView {
            List {
                ForEach($puzzleManager.puzzles) { $puzzle in
                    NavigationLink(destination: {
                        PuzzleView(puzzle: $puzzle, didWinPuzzle: didWinPuzzle)
                    }, label: {
                        Text(puzzle.displayName)
                    })
                        .disabled(puzzle.unlocked == false)
                }
            }
                #if DEBUG
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                        /// Reset puzzle state.
                        Button(action: {
                            puzzleManager.puzzles = Puzzle.initialSet
                            didResetPuzzles = true
                        }, label: {
                            Image(systemName: "circle.slash")
                                .font(.body.bold())
                        })
                            .alert("DEBUG: Reset All Puzzles", isPresented: $didResetPuzzles) {
                                Button("OK", role: .cancel) { }
                            }

                        
                        /// Unlock all puzzles.
                        Button(action: {
                            for idx in 0..<puzzleManager.puzzles.count {
                                puzzleManager.puzzles[idx].unlocked = true
                                didUnlockPuzzles = true
                            }
                        }, label: {
                            Image(systemName: "lock.open")
                                .font(.body.bold())
                        })
                            .alert("DEBUG: Unlocked All Puzzles", isPresented: $didUnlockPuzzles) {
                                Button("OK", role: .cancel) { }
                            }
                    })
                })
                #endif
        }
    }
    
    private func didWinPuzzle(_ puzzle: Puzzle) -> Void {
        guard let index = puzzleManager.puzzles.firstIndex(of: puzzle) else {
            assert(false, "Could not resolve index of \(puzzle)")
            return
        }
        
        if index < puzzleManager.puzzles.count {
            puzzleManager.puzzles[index + 1].unlocked = true
        }
    }
}
