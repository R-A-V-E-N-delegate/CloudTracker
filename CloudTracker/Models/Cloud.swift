import Foundation
import SwiftData

@Model
final class Cloud {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var cloudType: String
    var cloudDescription: String
    var captureDate: Date
    var latitude: Double?
    var longitude: Double?
    var locationName: String?

    init(
        id: UUID = UUID(),
        imageData: Data,
        cloudType: String,
        cloudDescription: String,
        captureDate: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.cloudType = cloudType
        self.cloudDescription = cloudDescription
        self.captureDate = captureDate
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
    }
}

extension Cloud {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: captureDate)
    }

    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }

    var displayLocation: String {
        if let name = locationName {
            return name
        } else if let lat = latitude, let lon = longitude {
            return String(format: "%.4f, %.4f", lat, lon)
        }
        return "Unknown Location"
    }
}
