import SwiftUI

// MARK: - Shared Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Ensure minimum touch target for iPad
            .padding()
            .background(Color(red: 0.996, green: 0.157, blue: 0.29))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .contentShape(Rectangle()) // Ensure entire area is tappable
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Ensure minimum touch target for iPad
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .contentShape(Rectangle()) // Ensure entire area is tappable
    }
}

