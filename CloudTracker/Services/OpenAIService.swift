import Foundation
import UIKit

/// Service for interacting with OpenAI's Vision API to identify cloud types
class OpenAIService {
    static let shared = OpenAIService()

    // MARK: - Configuration
    /// Replace with your actual OpenAI API key
    private let apiKey = "YOUR_OPENAI_API_KEY"
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    private init() {}

    // MARK: - Response Models

    struct CloudIdentification {
        let cloudType: String
        let description: String
    }

    struct OpenAIResponse: Codable {
        let choices: [Choice]

        struct Choice: Codable {
            let message: Message
        }

        struct Message: Codable {
            let content: String
        }
    }

    struct OpenAIError: Error, LocalizedError {
        let message: String

        var errorDescription: String? {
            message
        }
    }

    // MARK: - Public Methods

    /// Identifies the cloud type from an image
    /// - Parameter imageData: The image data to analyze
    /// - Returns: CloudIdentification with type and description
    func identifyCloud(from imageData: Data) async throws -> CloudIdentification {
        // Resize and compress image for API
        guard let image = UIImage(data: imageData),
              let compressedData = resizeAndCompress(image: image) else {
            throw OpenAIError(message: "Failed to process image")
        }

        let base64Image = compressedData.base64EncodedString()

        // Build request
        let request = try buildRequest(base64Image: base64Image)

        // Make API call
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError(message: "Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            if let errorBody = String(data: data, encoding: .utf8) {
                throw OpenAIError(message: "API error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw OpenAIError(message: "API error: \(httpResponse.statusCode)")
        }

        // Parse response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw OpenAIError(message: "No response content")
        }

        return parseCloudIdentification(from: content)
    }

    // MARK: - Private Methods

    private func resizeAndCompress(image: UIImage, maxDimension: CGFloat = 1024) -> Data? {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage?.jpegData(compressionQuality: 0.8)
    }

    private func buildRequest(base64Image: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw OpenAIError(message: "Invalid endpoint URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        You are a cloud identification expert. Analyze this image and identify the type of cloud shown.

        Respond in exactly this JSON format:
        {
            "cloudType": "<type of cloud>",
            "description": "<2-3 sentence description of the cloud characteristics and weather implications>"
        }

        Common cloud types include:
        - Cumulus: Puffy, cotton-like clouds with flat bases
        - Stratus: Gray, uniform layer covering the sky
        - Cirrus: Thin, wispy, high-altitude clouds
        - Cumulonimbus: Tall, towering storm clouds
        - Stratocumulus: Low, lumpy gray clouds
        - Altocumulus: Mid-level white/gray patches
        - Altostratus: Gray/blue mid-level sheet
        - Cirrostratus: Thin, high-level hazy layer
        - Cirrocumulus: Small, high-altitude patches
        - Nimbostratus: Dark, rain-producing layer

        If no clouds are visible or the image doesn't show the sky, indicate that in your response.
        """

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func parseCloudIdentification(from content: String) -> CloudIdentification {
        // Try to parse as JSON first
        if let data = content.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let cloudType = json["cloudType"],
           let description = json["description"] {
            return CloudIdentification(cloudType: cloudType, description: description)
        }

        // Try to extract JSON from markdown code block
        let jsonPattern = "```(?:json)?\\s*([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: jsonPattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let range = Range(match.range(at: 1), in: content) {
            let jsonString = String(content[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if let data = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
               let cloudType = json["cloudType"],
               let description = json["description"] {
                return CloudIdentification(cloudType: cloudType, description: description)
            }
        }

        // Fallback: return raw content
        return CloudIdentification(
            cloudType: "Unknown",
            description: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
