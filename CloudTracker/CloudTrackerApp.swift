import SwiftUI
import SwiftData

@main
struct CloudTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cloud.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CloudCollectionView()
                .tabItem {
                    Label("Collection", systemImage: "cloud.fill")
                }
                .tag(0)

            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera.fill")
                }
                .tag(1)
        }
        .tint(Color.skyBlue)
    }
}

extension Color {
    static let skyBlue = Color(red: 135/255, green: 206/255, blue: 235/255)
}

#Preview {
    ContentView()
        .modelContainer(for: Cloud.self, inMemory: true)
}
