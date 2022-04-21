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
                    /// Reset puzzle state.
                    Button(action: {
                        puzzleManager.puzzles = Puzzle.initialSet
                    }, label: {
                        Image(systemName: "circle.slash")
                            .font(.body.bold())
                    })
                #endif
        }
    }
}
