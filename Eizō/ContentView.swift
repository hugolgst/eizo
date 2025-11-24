import SwiftUI

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .video
    
    var body: some View {
        BottomNavigationBar(selectedTab: $selectedTab)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

