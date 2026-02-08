import Foundation
import UIKit
import SwiftUI

/// Service for generating sample cloud data for demo purposes
class SampleCloudService {
    static let shared = SampleCloudService()

    private init() {}

    /// Sample cloud definitions with realistic data
    struct SampleCloudData {
        let type: String
        let description: String
        let locationName: String
        let latitude: Double
        let longitude: Double
        let imageName: String
    }

    /// Predefined sample clouds
    let sampleClouds: [SampleCloudData] = [
        SampleCloudData(
            type: "Cumulus",
            description: "Puffy, cotton-like clouds with flat bases floating against a brilliant blue sky. These fair-weather clouds often appear during sunny afternoons and indicate stable atmospheric conditions.",
            locationName: "Santa Monica, CA",
            latitude: 34.0195,
            longitude: -118.4912,
            imageName: "cumulus"
        ),
        SampleCloudData(
            type: "Cirrus",
            description: "Thin, wispy clouds stretched across the high atmosphere like delicate brushstrokes. Found at altitudes above 20,000 feet, these ice crystal clouds often precede a change in weather.",
            locationName: "Sedona, AZ",
            latitude: 34.8697,
            longitude: -111.7610,
            imageName: "cirrus"
        ),
        SampleCloudData(
            type: "Stratus",
            description: "A uniform gray layer blanketing the sky like a soft veil. These low-level clouds often bring light drizzle or mist, creating a peaceful, subdued atmosphere perfect for contemplation.",
            locationName: "San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            imageName: "stratus"
        ),
        SampleCloudData(
            type: "Cumulonimbus",
            description: "A towering giant reaching from near the surface to the upper atmosphere. This dramatic thunderstorm cloud features an anvil-shaped top and brings lightning, heavy rain, and sometimes hail.",
            locationName: "Denver, CO",
            latitude: 39.7392,
            longitude: -104.9903,
            imageName: "cumulonimbus"
        )
    ]

    /// Load a real cloud image from the app bundle
    func loadCloudImage(for sample: SampleCloudData) -> Data? {
        guard let url = Bundle.main.url(forResource: sample.imageName, withExtension: "jpg") else {
            print("Could not find image: \(sample.imageName).jpg")
            return nil
        }

        do {
            let imageData = try Data(contentsOf: url)
            return imageData
        } catch {
            print("Error loading image \(sample.imageName): \(error)")
            return nil
        }
    }

    /// Create a sample Cloud object with real cloud image
    func createSampleCloud(from data: SampleCloudData, daysAgo: Int = 0) -> Cloud? {
        guard let imageData = loadCloudImage(for: data) else {
            return nil
        }

        let captureDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()

        return Cloud(
            imageData: imageData,
            cloudType: data.type,
            cloudDescription: data.description,
            captureDate: captureDate,
            latitude: data.latitude,
            longitude: data.longitude,
            locationName: data.locationName
        )
    }

    /// Create all sample clouds
    func createAllSampleClouds() -> [Cloud] {
        var clouds: [Cloud] = []

        for (index, sample) in sampleClouds.enumerated() {
            if let cloud = createSampleCloud(from: sample, daysAgo: index * 2) {
                clouds.append(cloud)
            }
        }

        return clouds
    }
}
