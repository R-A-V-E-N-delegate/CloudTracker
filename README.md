# CloudTracker

A SwiftUI iOS app for tracking and collecting cloud photos with AI-powered identification using OpenAI's Vision API.

## Features

- **Capture Clouds**: Take photos with your camera or select from your photo library
- **AI Identification**: Automatically identify cloud types using OpenAI GPT-4 Vision
- **Location Tagging**: Each cloud is tagged with the location where it was captured
- **Cloud Collection**: Browse your collection in a beautiful grid layout
- **Detailed View**: View full cloud details including type, description, date, and location
- **Delete Management**: Remove clouds from your collection when needed

## Supported Cloud Types

The app can identify various cloud types including:
- Cumulus
- Stratus
- Cirrus
- Cumulonimbus
- Stratocumulus
- Altocumulus
- Altostratus
- Cirrostratus
- Cirrocumulus
- Nimbostratus

## Requirements

- iOS 17.0+
- Xcode 15.0+
- OpenAI API key with GPT-4 Vision access

## Setup Instructions

1. **Clone or download the project**
   ```bash
   cd ~/Desktop/Projects/CloudTracker
   ```

2. **Open in Xcode**
   ```bash
   open CloudTracker.xcodeproj
   ```

3. **Configure OpenAI API Key**

   Open `CloudTracker/Services/OpenAIService.swift` and replace the placeholder API key:
   ```swift
   private let apiKey = "YOUR_OPENAI_API_KEY"
   ```

   Replace `YOUR_OPENAI_API_KEY` with your actual OpenAI API key.

4. **Build and Run**
   - Select your target device or simulator (iOS 17+)
   - Press Cmd+R or click the Run button

## Project Structure

```
CloudTracker/
├── CloudTracker.xcodeproj/
├── CloudTracker/
│   ├── CloudTrackerApp.swift      # App entry point
│   ├── Models/
│   │   └── Cloud.swift            # SwiftData model
│   ├── Views/
│   │   ├── CloudCollectionView.swift  # Main grid view
│   │   ├── CaptureView.swift          # Camera/photo picker
│   │   └── CloudDetailView.swift      # Detail view
│   ├── Services/
│   │   ├── OpenAIService.swift    # OpenAI Vision API
│   │   └── LocationService.swift  # CoreLocation service
│   ├── Assets.xcassets/
│   └── Info.plist
└── README.md
```

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Apple's new persistence framework (replaces Core Data)
- **CoreLocation** - Location services for geotagging
- **PhotosUI** - Photo picker integration
- **OpenAI Vision API** - Cloud identification

## Permissions

The app requires the following permissions:
- **Camera**: To take photos of clouds
- **Photo Library**: To select existing photos
- **Location**: To tag where clouds were captured

## Building from Command Line

```bash
cd ~/Desktop/Projects/CloudTracker
xcodebuild -project CloudTracker.xcodeproj \
           -scheme CloudTracker \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
           build
```

## License

This project is provided as-is for educational purposes.
