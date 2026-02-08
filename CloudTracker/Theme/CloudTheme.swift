import SwiftUI

/// Dreamy, cloud-inspired theme for CloudTracker
enum CloudTheme {
    // MARK: - Colors

    /// Primary accent color - soft sky blue
    static let accent = Color(red: 0.53, green: 0.81, blue: 0.92)

    /// Secondary accent - warm sunset pink
    static let accentSecondary = Color(red: 0.98, green: 0.80, blue: 0.82)

    /// Soft lavender for variety
    static let accentTertiary = Color(red: 0.85, green: 0.82, blue: 0.95)

    /// Background gradient colors
    static let gradientTop = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let gradientBottom = Color(red: 0.93, green: 0.95, blue: 0.98)

    /// Warm sunset gradient for headers
    static let sunsetTop = Color(red: 0.98, green: 0.95, blue: 0.97)
    static let sunsetBottom = Color(red: 0.95, green: 0.97, blue: 1.0)

    /// Card background
    static let cardBackground = Color.white

    /// Soft shadow color
    static let shadowColor = Color(red: 0.7, green: 0.75, blue: 0.85).opacity(0.25)

    // MARK: - Corner Radii

    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 20
    static let cornerRadiusLarge: CGFloat = 28

    // MARK: - Shadows

    static let shadowRadiusSoft: CGFloat = 15
    static let shadowRadiusMedium: CGFloat = 20
    static let shadowYOffset: CGFloat = 8

    // MARK: - Gradients

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [gradientTop, gradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var sunsetGradient: LinearGradient {
        LinearGradient(
            colors: [sunsetTop, sunsetBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white, Color(red: 0.98, green: 0.99, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accent.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - View Modifiers

/// Soft cloud-like card style
struct CloudCardStyle: ViewModifier {
    var cornerRadius: CGFloat = CloudTheme.cornerRadiusMedium

    func body(content: Content) -> some View {
        content
            .background(CloudTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: CloudTheme.shadowColor,
                radius: CloudTheme.shadowRadiusSoft,
                x: 0,
                y: CloudTheme.shadowYOffset
            )
    }
}

/// Dreamy background gradient style
struct DreamyBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(CloudTheme.backgroundGradient.ignoresSafeArea())
    }
}

/// Soft floating button style
struct CloudButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(isPrimary ? .white : CloudTheme.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isPrimary {
                        CloudTheme.accentGradient
                    } else {
                        CloudTheme.accent.opacity(0.12)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadiusMedium, style: .continuous))
            .shadow(
                color: isPrimary ? CloudTheme.accent.opacity(0.3) : Color.clear,
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cloudCard(cornerRadius: CGFloat = CloudTheme.cornerRadiusMedium) -> some View {
        modifier(CloudCardStyle(cornerRadius: cornerRadius))
    }

    func dreamyBackground() -> some View {
        modifier(DreamyBackgroundStyle())
    }
}

// MARK: - Deprecated Color Extension Update

extension Color {
    /// Updated sky blue to match the dreamy theme
    static let skyBlue = CloudTheme.accent
}
