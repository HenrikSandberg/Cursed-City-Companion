import SwiftUI

struct ScoreView: View {
    let title: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(CCTheme.cursedGold)
            Text("\(score)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.85)))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(CCTheme.cursedGold.opacity(0.35), lineWidth: 1))
    }
}
