import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let growthGreen     = Color(red: 0.188, green: 0.820, blue: 0.345)
    static let deepGreen       = Color(red: 0.043, green: 0.518, blue: 0.235)
    static let softGreen       = Color(red: 0.878, green: 0.969, blue: 0.894)
    static let cardBg          = Color(UIColor.systemBackground)
    static let screenBg        = Color(UIColor.systemGroupedBackground)
    static let secondaryCardBg = Color(UIColor.secondarySystemGroupedBackground)
}

// MARK: - Card Modifiers
struct PrimaryCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 4)
    }
}

struct SectionCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.secondaryCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func primaryCard() -> some View { modifier(PrimaryCard()) }
    func sectionCard() -> some View { modifier(SectionCard()) }
}

// MARK: - Currency (Sabit TL)
enum TLFormatter {
    static func format(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        f.groupingSeparator = "."
        f.decimalSeparator = ","
        let n = f.string(from: NSNumber(value: value)) ?? "0"
        return "₺\(n)"
    }

    static func compact(_ value: Double) -> String {
        switch abs(value) {
        case 1_000_000_000...: return String(format: "₺%.2f Milyar", value / 1_000_000_000)
        case 1_000_000...:    return String(format: "₺%.2f Milyon", value / 1_000_000)
        case 1_000...:        return String(format: "₺%.1fK", value / 1_000)
        default:              return format(value)
        }
    }
}

// MARK: - Haptics
enum HapticFeedback {
    static func light()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium()  { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

// MARK: - Animation Presets
extension Animation {
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.82)
    static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.88)
}

// MARK: - Gradients
extension LinearGradient {
    static let greenFade = LinearGradient(
        colors: [Color.growthGreen.opacity(0.85), Color.growthGreen.opacity(0.05)],
        startPoint: .top, endPoint: .bottom
    )
    static let heroGradient = LinearGradient(
        colors: [Color.deepGreen, Color.growthGreen],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}
