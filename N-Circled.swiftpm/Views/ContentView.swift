import SwiftUI

struct ContentView: View {
    
    @StateObject private var puzzleManager: PuzzleManager = .init()
    
    var body: some View {
        NavigationView {
            List {
                ForEach($puzzleManager.puzzles) { $puzzle in
                    NavigationLink(destination: {
                        PuzzleView(puzzle: $puzzle)
                    }, label: {
                        Text(puzzle.name)
                    })
                }
            }
                #if DEBUG
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                        /// Reset puzzle state.
                        Button(action: {
                            puzzleManager.puzzles = Puzzle.initialSet
                        }, label: {
                            Image(systemName: "circle.slash")
                                .font(.body.bold())
                        })
                        
                        /// Unlock all puzzles.
                        Button(action: {
                            for idx in 0..<puzzleManager.puzzles.count {
                                puzzleManager.puzzles[idx].unlocked = true
                            }
                        }, label: {
                            Image(systemName: "lock.open")
                                .font(.body.bold())
                        })
                    })
                })
                #endif
        }
    }
}
