import Foundation
import SwiftUI

private struct IslandFontScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

extension EnvironmentValues {
    var islandFontScale: CGFloat {
        get { self[IslandFontScaleKey.self] }
        set { self[IslandFontScaleKey.self] = newValue }
    }
}

extension Font {
    static func islandSystem(
        size: CGFloat,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil,
        scale: CGFloat
    ) -> Font {
        .system(size: size * scale, weight: weight, design: design)
    }
}

struct IslandMarkdownText: View {
    let markdown: String

    var body: some View {
        Text(attributedMarkdown)
    }

    private var attributedMarkdown: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
    }
}
