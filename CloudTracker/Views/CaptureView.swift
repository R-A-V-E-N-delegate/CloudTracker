import SwiftUI
import PhotosUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationService = LocationService.shared

    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var processingStatus = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessSheet = false
    @State private var savedCloud: Cloud?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Header
                VStack(spacing: 12) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.skyBlue)

                    Text("Capture a Cloud")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Take a photo or choose from your library\nto identify the cloud type")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                if isProcessing {
                    processingView
                } else {
                    captureButtonsView
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Capture")
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    await handleSelectedPhoto(newValue)
                }
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    Task {
                        await processImage(image)
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showSuccessSheet) {
                if let cloud = savedCloud {
                    CloudDetailView(cloud: cloud, isNewCapture: true)
                }
            }
        }
    }

    // MARK: - Subviews

    private var captureButtonsView: some View {
        VStack(spacing: 16) {
            // Camera button
            Button {
                showCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.skyBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // Photo picker
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .foregroundStyle(Color.skyBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.skyBlue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 24)
    }

    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.skyBlue)

            Text(processingStatus)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Methods

    private func handleSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await processImage(image)
            }
        } catch {
            alertMessage = "Failed to load image: \(error.localizedDescription)"
            showAlert = true
        }

        selectedItem = nil
    }

    private func processImage(_ image: UIImage) async {
        isProcessing = true

        // Get location
        processingStatus = "Getting location..."
        let location = await locationService.getCurrentLocation()

        // Get image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Failed to process image"
            showAlert = true
            isProcessing = false
            return
        }

        // Identify cloud
        processingStatus = "Identifying cloud type..."

        do {
            let identification = try await OpenAIService.shared.identifyCloud(from: imageData)

            // Get location name if we have coordinates
            var locationName: String?
            if let location = location {
                locationName = await locationService.getLocationName(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }

            // Create and save cloud
            processingStatus = "Saving to collection..."

            let cloud = Cloud(
                imageData: imageData,
                cloudType: identification.cloudType,
                cloudDescription: identification.description,
                captureDate: Date(),
                latitude: location?.coordinate.latitude,
                longitude: location?.coordinate.longitude,
                locationName: locationName
            )

            modelContext.insert(cloud)
            try modelContext.save()

            savedCloud = cloud
            showSuccessSheet = true

        } catch {
            alertMessage = "Failed to identify cloud: \(error.localizedDescription)"
            showAlert = true
        }

        isProcessing = false
        capturedImage = nil
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CaptureView()
        .modelContainer(for: Cloud.self, inMemory: true)
}
