import SwiftUI
import SwiftData

struct CloudCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cloud.captureDate, order: .reverse) private var clouds: [Cloud]

    @State private var selectedCloud: Cloud?
    @State private var isAddingSamples = false
    @State private var hasCheckedForSamples = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if clouds.isEmpty {
                    emptyStateView
                } else {
                    cloudGridView
                }
            }
            .navigationTitle("My Clouds")
            .dreamyBackground()
            .sheet(item: $selectedCloud) { cloud in
                CloudDetailView(cloud: cloud)
            }
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            addSampleClouds()
                        } label: {
                            Label("Add Sample Clouds", systemImage: "plus.cloud")
                        }
                        .disabled(isAddingSamples)

                        if !clouds.isEmpty {
                            Button(role: .destructive) {
                                clearAllClouds()
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(CloudTheme.accent)
                    }
                }
                #endif
            }
            .onAppear {
                // Auto-add sample clouds on first launch for demo
                #if DEBUG
                if !hasCheckedForSamples && clouds.isEmpty {
                    hasCheckedForSamples = true
                    addSampleClouds()
                }
                #endif
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Animated cloud icon
            ZStack {
                Circle()
                    .fill(CloudTheme.accent.opacity(0.1))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(CloudTheme.accent.opacity(0.08))
                    .frame(width: 200, height: 200)

                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(CloudTheme.accent, CloudTheme.accentSecondary)
            }

            VStack(spacing: 12) {
                Text("No Clouds Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Capture your first cloud photo\nusing the Capture tab")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            #if DEBUG
            Button {
                addSampleClouds()
            } label: {
                HStack(spacing: 8) {
                    if isAddingSamples {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text("Add Sample Clouds")
                }
            }
            .buttonStyle(CloudButtonStyle())
            .padding(.horizontal, 40)
            .padding(.top, 8)
            .disabled(isAddingSamples)
            #endif
        }
        .padding()
    }

    private var cloudGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(clouds) { cloud in
                    CloudCardView(cloud: cloud)
                        .onTapGesture {
                            selectedCloud = cloud
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100) // Space for floating tab bar
        }
    }

    // MARK: - Methods

    private func addSampleClouds() {
        isAddingSamples = true

        DispatchQueue.global(qos: .userInitiated).async {
            let samples = SampleCloudService.shared.createAllSampleClouds()

            DispatchQueue.main.async {
                for cloud in samples {
                    modelContext.insert(cloud)
                }
                try? modelContext.save()
                isAddingSamples = false
            }
        }
    }

    private func clearAllClouds() {
        for cloud in clouds {
            modelContext.delete(cloud)
        }
        try? modelContext.save()
    }
}

// MARK: - Cloud Card View

struct CloudCardView: View {
    let cloud: Cloud

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cloud image
            ZStack(alignment: .bottomLeading) {
                if let uiImage = UIImage(data: cloud.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 130)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [CloudTheme.accent.opacity(0.3), CloudTheme.accentSecondary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 130)
                        .overlay {
                            Image(systemName: "cloud.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                }
            }

            // Cloud info
            VStack(alignment: .leading, spacing: 6) {
                Text(cloud.cloudType)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(cloud.formattedDate)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusMedium, style: .continuous))
        .shadow(color: CloudTheme.shadowColor, radius: CloudTheme.shadowRadiusSoft, x: 0, y: CloudTheme.shadowYOffset)
    }
}

#Preview {
    CloudCollectionView()
        .modelContainer(for: Cloud.self, inMemory: true)
}
