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
                VStack(spacing: 20) {
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

                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .dreamyBackground()
            .navigationTitle(isNewCapture ? "Cloud Identified!" : "Cloud Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(CloudTheme.accent)
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
                    .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusLarge, style: .continuous))
                    .shadow(color: CloudTheme.shadowColor, radius: CloudTheme.shadowRadiusMedium, x: 0, y: CloudTheme.shadowYOffset)
            }
        }
    }

    private var cloudTypeBadge: some View {
        Text(cloud.cloudType)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(CloudTheme.accentGradient)
                    .shadow(color: CloudTheme.accent.opacity(0.4), radius: 12, x: 0, y: 6)
            )
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(CloudTheme.accent)
                Text("Description")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Text(cloud.cloudDescription)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusMedium, style: .continuous))
        .shadow(color: CloudTheme.shadowColor, radius: CloudTheme.shadowRadiusSoft, x: 0, y: CloudTheme.shadowYOffset)
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
                .padding(.leading, 56)

            // Location
            DetailRow(
                icon: "location.fill",
                title: "Location",
                value: cloud.displayLocation
            )

            if cloud.hasLocation {
                Divider()
                    .padding(.leading, 56)

                // Coordinates
                DetailRow(
                    icon: "mappin.circle",
                    title: "Coordinates",
                    value: String(format: "%.4f, %.4f", cloud.latitude ?? 0, cloud.longitude ?? 0)
                )
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusMedium, style: .continuous))
        .shadow(color: CloudTheme.shadowColor, radius: CloudTheme.shadowRadiusSoft, x: 0, y: CloudTheme.shadowYOffset)
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
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusMedium, style: .continuous))
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
            ZStack {
                Circle()
                    .fill(CloudTheme.accent.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CloudTheme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
