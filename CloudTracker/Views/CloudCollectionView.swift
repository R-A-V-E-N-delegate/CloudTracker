import SwiftUI
import SwiftData

struct CloudCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cloud.captureDate, order: .reverse) private var clouds: [Cloud]

    @State private var selectedCloud: Cloud?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
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
            .background(Color(.systemGroupedBackground))
            .sheet(item: $selectedCloud) { cloud in
                CloudDetailView(cloud: cloud)
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 80))
                .foregroundStyle(Color.skyBlue)

            Text("No Clouds Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Capture your first cloud photo\nusing the Capture tab")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var cloudGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(clouds) { cloud in
                    CloudCardView(cloud: cloud)
                        .onTapGesture {
                            selectedCloud = cloud
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Cloud Card View

struct CloudCardView: View {
    let cloud: Cloud

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cloud image
            if let uiImage = UIImage(data: cloud.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }
            }

            // Cloud info
            VStack(alignment: .leading, spacing: 4) {
                Text(cloud.cloudType)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(cloud.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CloudCollectionView()
        .modelContainer(for: Cloud.self, inMemory: true)
}
