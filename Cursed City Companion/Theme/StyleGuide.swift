import SwiftUI

public struct ArcadeBackground: View {
    public init() {}
    public var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0A0A0C), Color(hex: 0x0A0A0C)], startPoint: .top, endPoint: .bottom)
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0xAD1F2A).opacity(0.65), .clear]),
                center: .init(x: 0.55, y: 0.72),
                startRadius: 10, endRadius: 500
            )
            LinearGradient(colors: [Color.black.opacity(0.5), .clear, .clear, Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            NoiseOverlay(opacity: 0.05)
        }
        .ignoresSafeArea()
    }
}

public struct NoiseOverlay: View {
    public var opacity: CGFloat = 0.05
    public init(opacity: CGFloat = 0.05) { self.opacity = opacity }
    public var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 3
            for x in stride(from: 0, to: size.width, by: step) {
                for y in stride(from: 0, to: size.height, by: step) {
                    let gray = Double.random(in: 0.42...0.58)
                    ctx.fill(Path(CGRect(x: x, y: y, width: step, height: step)), with: .color(.white.opacity(gray * opacity)))
                }
            }
        }
        .allowsHitTesting(false)
        .blendMode(.overlay)
    }
}

public enum CCTheme {
    public static let bloodRed = Color(hex: 0x8E0F12)
    public static let vampireViolet = Color(hex: 0x3E143E)
    public static let cursedGold = Color(hex: 0xC79B42)
    public static let darkstone = Color(hex: 0x121315)
    public static let parchment = Color(hex: 0xEDE3CF)
    public static let brass = Color(hex: 0xC6A15A)
    public static let teal = Color(hex: 0x49B0BC)
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >>  8) & 0xff) / 255,
                  blue: Double((hex >>  0) & 0xff) / 255,
                  opacity: alpha)
    }
}

public extension View {
    func ccBackground() -> some View { background(ArcadeBackground()) }
    func ccPanel() -> some View {
        self
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CCTheme.cursedGold.opacity(0.35), lineWidth: 1))
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
            )
    }
    func ccToolbar() -> some View {
        self.toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.6), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

public struct CCPrimaryButton: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 10).padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(CCTheme.bloodRed.opacity(configuration.isPressed ? 0.9 : 1.0)))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(CCTheme.cursedGold.opacity(0.5), lineWidth: 1))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: configuration.isPressed ? 0 : 6, x: 0, y: 4)
    }
}

public struct CCSecondaryButton: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.white.opacity(configuration.isPressed ? 0.08 : 0.06)))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(CCTheme.cursedGold.opacity(0.35), lineWidth: 1))
            .foregroundStyle(CCTheme.parchment)
    }
}
