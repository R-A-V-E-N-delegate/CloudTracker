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
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                CloudCollectionView()
                    .tag(0)

                CaptureView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom floating tab bar
            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 60)
                .padding(.bottom, 20)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "cloud.fill",
                title: "Collection",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }

            TabBarButton(
                icon: "camera.fill",
                title: "Capture",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: CloudTheme.shadowColor, radius: 20, x: 0, y: 10)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolEffect(.bounce, value: isSelected)

                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? CloudTheme.accent : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? CloudTheme.accent.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Cloud.self, inMemory: true)
}
