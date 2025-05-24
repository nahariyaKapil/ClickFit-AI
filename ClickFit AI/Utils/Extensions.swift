import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // Modern glass morphism effect
    func glassMorphism() -> some View {
        self
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    // Modern shadow effect
    func modernShadow(color: Color = .black, radius: CGFloat = 10, opacity: Double = 0.3) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 5)
    }
    
    // Gradient text modifier
    func gradientForeground(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> some View {
        self.foregroundStyle(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Date {
    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var dayOfWeek: String {
        formatted(as: "EEEE")
    }
    
    var shortDate: String {
        formatted(as: "MMM d")
    }
}

// Modern color palette
extension Color {
    static let modernBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.05, green: 0.05, blue: 0.1),
            Color.black
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.05)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [Color.cyan, Color.blue]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

// Animation helpers
extension Animation {
    static let modernSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let smoothEaseOut = Animation.easeOut(duration: 0.3)
}