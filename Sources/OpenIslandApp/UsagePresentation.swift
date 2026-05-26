import Foundation
import OpenIslandCore

enum UsageSeverity: Equatable, Sendable {
    case normal
    case warning
    case critical

    static func severity(for usedPercentage: Double) -> UsageSeverity {
        switch usedPercentage {
        case 90...:
            .critical
        case 70..<90:
            .warning
        default:
            .normal
        }
    }
}

struct UsageProviderPresentation: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let windows: [UsageWindowPresentation]

    var inlineText: String {
        ([title] + windows.map(\.inlineText)).joined(separator: " ")
    }

    var shortTitle: String {
        switch id {
        case "claude":
            "Cl"
        case "codex":
            "Cx"
        default:
            String(title.prefix(2))
        }
    }

    static func providers(
        claude: ClaudeUsageSnapshot?,
        codex: CodexUsageSnapshot?,
        showCodex: Bool
    ) -> [UsageProviderPresentation] {
        var providers: [UsageProviderPresentation] = []

        if let claude, claude.isEmpty == false {
            var windows: [UsageWindowPresentation] = []

            if let fiveHour = claude.fiveHour {
                windows.append(
                    UsageWindowPresentation(
                        id: "claude-5h",
                        label: "5h",
                        usedPercentage: fiveHour.usedPercentage,
                        resetsAt: fiveHour.resetsAt
                    )
                )
            }

            if let sevenDay = claude.sevenDay {
                windows.append(
                    UsageWindowPresentation(
                        id: "claude-7d",
                        label: "7d",
                        usedPercentage: sevenDay.usedPercentage,
                        resetsAt: sevenDay.resetsAt
                    )
                )
            }

            if windows.isEmpty == false {
                providers.append(
                    UsageProviderPresentation(
                        id: "claude",
                        title: "Claude",
                        windows: windows
                    )
                )
            }
        }

        if showCodex, let codex, codex.isEmpty == false {
            let windows = codex.windows.map { window in
                UsageWindowPresentation(
                    id: "codex-\(window.key)",
                    label: canonicalLabel(for: window),
                    usedPercentage: window.usedPercentage,
                    resetsAt: window.resetsAt
                )
            }

            if windows.isEmpty == false {
                providers.append(
                    UsageProviderPresentation(
                        id: "codex",
                        title: "Codex",
                        windows: windows
                    )
                )
            }
        }

        return providers
    }

    private static func canonicalLabel(for window: CodexUsageWindow) -> String {
        switch window.windowMinutes {
        case 300:
            "5h"
        case 10_080:
            "7d"
        default:
            window.label
        }
    }
}

struct UsageWindowPresentation: Identifiable, Equatable, Sendable {
    let id: String
    let label: String
    let usedPercentage: Double
    let resetsAt: Date?

    var roundedUsedPercentage: Int {
        Int(usedPercentage.rounded())
    }

    var inlineText: String {
        "\(label) \(roundedUsedPercentage)%"
    }

    var severity: UsageSeverity {
        UsageSeverity.severity(for: usedPercentage)
    }
}
