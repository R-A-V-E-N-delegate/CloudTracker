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
        let gradientColors: [Color]
    }

    /// Predefined sample clouds
    let sampleClouds: [SampleCloudData] = [
        SampleCloudData(
            type: "Cumulus",
            description: "Puffy, cotton-like clouds with flat bases floating against a brilliant blue sky. These fair-weather clouds often appear during sunny afternoons and indicate stable atmospheric conditions.",
            locationName: "Santa Monica, CA",
            latitude: 34.0195,
            longitude: -118.4912,
            gradientColors: [Color(red: 0.53, green: 0.81, blue: 0.92), Color(red: 0.95, green: 0.95, blue: 1.0)]
        ),
        SampleCloudData(
            type: "Cirrus",
            description: "Thin, wispy clouds stretched across the high atmosphere like delicate brushstrokes. Found at altitudes above 20,000 feet, these ice crystal clouds often precede a change in weather.",
            locationName: "Sedona, AZ",
            latitude: 34.8697,
            longitude: -111.7610,
            gradientColors: [Color(red: 0.98, green: 0.85, blue: 0.75), Color(red: 0.85, green: 0.92, blue: 0.98)]
        ),
        SampleCloudData(
            type: "Stratus",
            description: "A uniform gray layer blanketing the sky like a soft veil. These low-level clouds often bring light drizzle or mist, creating a peaceful, subdued atmosphere perfect for contemplation.",
            locationName: "San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            gradientColors: [Color(red: 0.85, green: 0.87, blue: 0.90), Color(red: 0.95, green: 0.95, blue: 0.97)]
        ),
        SampleCloudData(
            type: "Cumulonimbus",
            description: "A towering giant reaching from near the surface to the upper atmosphere. This dramatic thunderstorm cloud features an anvil-shaped top and brings lightning, heavy rain, and sometimes hail.",
            locationName: "Denver, CO",
            latitude: 39.7392,
            longitude: -104.9903,
            gradientColors: [Color(red: 0.4, green: 0.45, blue: 0.55), Color(red: 0.75, green: 0.78, blue: 0.85)]
        )
    ]

    /// Generate a placeholder cloud image with gradient
    func generateCloudImage(for sample: SampleCloudData, size: CGSize = CGSize(width: 800, height: 600)) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Create gradient
            let colors = sample.gradientColors.map { UIColor($0).cgColor }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0.0, 1.0]

            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) else {
                return
            }

            // Draw background gradient
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y: size.height),
                options: []
            )

            // Draw stylized clouds
            cgContext.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)

            // Draw multiple cloud puffs based on type
            switch sample.type {
            case "Cumulus":
                drawCumulusCloud(in: cgContext, size: size)
            case "Cirrus":
                drawCirrusCloud(in: cgContext, size: size)
            case "Stratus":
                drawStratusCloud(in: cgContext, size: size)
            case "Cumulonimbus":
                drawCumulonimbusCloud(in: cgContext, size: size)
            default:
                drawCumulusCloud(in: cgContext, size: size)
            }

            // Add cloud type label
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .paragraphStyle: paragraphStyle
            ]

            let text = sample.type
            let textRect = CGRect(x: 20, y: size.height - 50, width: size.width - 40, height: 40)
            text.draw(in: textRect, withAttributes: attrs)
        }

        return image.jpegData(compressionQuality: 0.9)
    }

    // MARK: - Cloud Drawing Methods

    private func drawCumulusCloud(in context: CGContext, size: CGSize) {
        // Main fluffy cumulus cloud in center
        let centerX = size.width / 2
        let centerY = size.height / 2

        context.setFillColor(UIColor.white.withAlphaComponent(0.95).cgColor)

        // Large central puff
        context.fillEllipse(in: CGRect(x: centerX - 100, y: centerY - 50, width: 200, height: 120))
        // Left puff
        context.fillEllipse(in: CGRect(x: centerX - 180, y: centerY - 20, width: 140, height: 90))
        // Right puff
        context.fillEllipse(in: CGRect(x: centerX + 40, y: centerY - 30, width: 150, height: 100))
        // Top puffs
        context.fillEllipse(in: CGRect(x: centerX - 60, y: centerY - 100, width: 130, height: 90))
        context.fillEllipse(in: CGRect(x: centerX + 20, y: centerY - 90, width: 100, height: 70))

        // Smaller clouds in background
        context.setFillColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 100, width: 100, height: 60))
        context.fillEllipse(in: CGRect(x: 100, y: 90, width: 80, height: 50))
        context.fillEllipse(in: CGRect(x: size.width - 180, y: 120, width: 120, height: 70))
    }

    private func drawCirrusCloud(in context: CGContext, size: CGSize) {
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        context.setLineWidth(3)
        context.setLineCap(.round)

        // Draw wispy streaks
        let streaks = [
            (start: CGPoint(x: 50, y: 150), end: CGPoint(x: 350, y: 120)),
            (start: CGPoint(x: 200, y: 200), end: CGPoint(x: 550, y: 160)),
            (start: CGPoint(x: 100, y: 280), end: CGPoint(x: 450, y: 250)),
            (start: CGPoint(x: 300, y: 350), end: CGPoint(x: 700, y: 300)),
            (start: CGPoint(x: 400, y: 180), end: CGPoint(x: 750, y: 140))
        ]

        for streak in streaks {
            context.move(to: streak.start)
            context.addQuadCurve(
                to: streak.end,
                control: CGPoint(
                    x: (streak.start.x + streak.end.x) / 2,
                    y: streak.start.y - 30
                )
            )
            context.strokePath()
        }

        // Add some soft puffs
        context.setFillColor(UIColor.white.withAlphaComponent(0.4).cgColor)
        context.fillEllipse(in: CGRect(x: 150, y: 130, width: 60, height: 30))
        context.fillEllipse(in: CGRect(x: 400, y: 170, width: 50, height: 25))
        context.fillEllipse(in: CGRect(x: 550, y: 280, width: 70, height: 35))
    }

    private func drawStratusCloud(in context: CGContext, size: CGSize) {
        // Draw horizontal layers
        context.setFillColor(UIColor.white.withAlphaComponent(0.7).cgColor)

        // Multiple overlapping horizontal ellipses
        for i in 0..<5 {
            let y = CGFloat(100 + i * 80)
            let width = size.width + 100
            context.fillEllipse(in: CGRect(x: -50, y: y, width: width, height: 60))
        }

        // Subtle darker layer for depth
        context.setFillColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context.fillEllipse(in: CGRect(x: -50, y: 200, width: size.width + 100, height: 80))
        context.fillEllipse(in: CGRect(x: -50, y: 340, width: size.width + 100, height: 70))
    }

    private func drawCumulonimbusCloud(in context: CGContext, size: CGSize) {
        let centerX = size.width / 2

        // Darker base
        context.setFillColor(UIColor(white: 0.6, alpha: 0.9).cgColor)
        context.fillEllipse(in: CGRect(x: centerX - 200, y: size.height - 200, width: 400, height: 100))
        context.fillEllipse(in: CGRect(x: centerX - 150, y: size.height - 180, width: 300, height: 80))

        // Towering middle section - gradient from dark to light
        context.setFillColor(UIColor(white: 0.75, alpha: 0.9).cgColor)
        context.fillEllipse(in: CGRect(x: centerX - 160, y: size.height - 320, width: 320, height: 180))
        context.fillEllipse(in: CGRect(x: centerX - 120, y: size.height - 380, width: 240, height: 140))

        // Bright anvil top
        context.setFillColor(UIColor.white.withAlphaComponent(0.95).cgColor)
        context.fillEllipse(in: CGRect(x: centerX - 180, y: 60, width: 360, height: 120))
        context.fillEllipse(in: CGRect(x: centerX - 100, y: 40, width: 200, height: 80))
        context.fillEllipse(in: CGRect(x: centerX - 140, y: 100, width: 280, height: 100))

        // Anvil extension
        context.fillEllipse(in: CGRect(x: centerX + 80, y: 50, width: 150, height: 70))
    }

    /// Create a sample Cloud object with generated image
    func createSampleCloud(from data: SampleCloudData, daysAgo: Int = 0) -> Cloud? {
        guard let imageData = generateCloudImage(for: data) else {
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
