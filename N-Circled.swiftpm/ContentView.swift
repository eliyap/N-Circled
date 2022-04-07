import SwiftUI

struct ContentView: View {
    
    @StateObject private var spinnerHolder: SpinnerHolder = .init()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, WWDC!")
            Text("\(spinnerHolder.spinners.count)")
            DoodleView(spinnerHolder: spinnerHolder)
                .border(Color.red)
                .onAppear(perform: {
                    test()
                })
            GeometryReader { geo in
                CASpinner(size: geo.size)
            }
                .border(Color.red)
        }
    }
}

final class SpinnerHolder: ObservableObject {
    @Published var spinners: [Spinner] = []
}
