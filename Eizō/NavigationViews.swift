import SwiftUI

enum NavigationTab: String, CaseIterable {
    case video = "Video"
    case glossary = "Glossary"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .video:
            return "play.rectangle.fill"
        case .glossary:
            return "book.fill"
        case .settings:
            return "gear"
        }
    }
}

struct BottomNavigationBar: View {
    @Binding var selectedTab: NavigationTab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VideoFeedView()
                .ignoresSafeArea()
                .tabItem {
                    Label(NavigationTab.video.rawValue, systemImage: NavigationTab.video.icon)
                }
                .tag(NavigationTab.video)
            
            GlossaryView()
                .tabItem {
                    Label(NavigationTab.glossary.rawValue, systemImage: NavigationTab.glossary.icon)
                }
                .tag(NavigationTab.glossary)
            
            SettingsView()
                .tabItem {
                    Label(NavigationTab.settings.rawValue, systemImage: NavigationTab.settings.icon)
                }
                .tag(NavigationTab.settings)
        }
        .tint(.white)
        .background(Color.clear)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor.clear
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            
            appearance.shadowColor = UIColor.clear
            
            UITabBar.appearance().standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct GlossaryView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Glossary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("Your saved words and phrases will appear here")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("App settings and preferences")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct BottomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationBar(selectedTab: .constant(.video))
    }
}
