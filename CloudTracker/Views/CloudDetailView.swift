import SwiftUI
import SwiftData

struct CloudDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let cloud: Cloud
    var isNewCapture: Bool = false

    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Cloud Image
                    cloudImageSection

                    // Cloud Type Badge
                    cloudTypeBadge

                    // Description
                    descriptionSection

                    // Details
                    detailsSection

                    // Delete Button
                    if !isNewCapture {
                        deleteButton
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNewCapture ? "Cloud Identified!" : "Cloud Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Delete Cloud",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteCloud()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this cloud from your collection?")
            }
        }
    }

    // MARK: - Subviews

    private var cloudImageSection: some View {
        Group {
            if let uiImage = UIImage(data: cloud.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
        }
    }

    private var cloudTypeBadge: some View {
        Text(cloud.cloudType)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.skyBlue)
            .clipShape(Capsule())
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(cloud.cloudDescription)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            // Date
            DetailRow(
                icon: "calendar",
                title: "Captured",
                value: cloud.formattedDate
            )

            Divider()
                .padding(.leading, 52)

            // Location
            DetailRow(
                icon: "location.fill",
                title: "Location",
                value: cloud.displayLocation
            )

            if cloud.hasLocation {
                Divider()
                    .padding(.leading, 52)

                // Coordinates
                DetailRow(
                    icon: "mappin.circle",
                    title: "Coordinates",
                    value: String(format: "%.4f, %.4f", cloud.latitude ?? 0, cloud.longitude ?? 0)
                )
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete from Collection", systemImage: "trash")
                .font(.headline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.top, 8)
    }

    // MARK: - Methods

    private func deleteCloud() {
        modelContext.delete(cloud)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.skyBlue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Cloud.self, configurations: config)

    let sampleCloud = Cloud(
        imageData: Data(),
        cloudType: "Cumulus",
        cloudDescription: "Puffy, cotton-like clouds with flat bases. These fair-weather clouds often appear during sunny days and can develop into larger storm clouds if conditions change.",
        latitude: 37.7749,
        longitude: -122.4194,
        locationName: "San Francisco, CA"
    )

    return CloudDetailView(cloud: sampleCloud)
        .modelContainer(container)
}
