import ActivityKit
import SwiftUI
import WidgetKit

/// Lock Screen / Dynamic Island presentation of the rest timer.
///
/// The countdown uses `Text(timerInterval:)` / `ProgressView(timerInterval:)`,
/// which the system ticks in its own process from a wall-clock range. That is
/// why a running rest costs zero ActivityKit updates: we only push on real
/// state transitions (start, +/-, pause, skip).
@available(iOS 16.2, *)
struct RestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Rest", systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.system(.title3, design: .rounded).monospacedDigit())
                        .fontWeight(.semibold)
                        .frame(maxWidth: 64, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.exerciseName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.state.setLine)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        TimerBar(state: context.state)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
            } compactTrailing: {
                CountdownText(state: context.state)
                    // Constrained: the digits reflow every second and would
                    // otherwise jitter the pill's width.
                    .frame(maxWidth: 44)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
            }
            .keylineTint(.orange)
        }
    }
}

/// Ticking countdown, or a frozen value while paused.
@available(iOS 16.2, *)
private struct CountdownText: View {
    let state: RestTimerAttributes.ContentState

    var body: some View {
        if state.isPaused {
            Text(state.pausedDisplay)
        } else {
            Text(timerInterval: state.startDate...state.endDate, countsDown: true)
                .multilineTextAlignment(.trailing)
        }
    }
}

@available(iOS 16.2, *)
private struct TimerBar: View {
    let state: RestTimerAttributes.ContentState

    var body: some View {
        if state.isPaused {
            ProgressView(value: 0)
                .tint(.orange)
        } else {
            ProgressView(
                timerInterval: state.startDate...state.endDate,
                countsDown: true,
                label: { EmptyView() },
                currentValueLabel: { EmptyView() }
            )
            .tint(.orange)
        }
    }
}

@available(iOS 16.2, *)
private struct LockScreenView: View {
    let state: RestTimerAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.exerciseName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(state.setLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 12)
                CountdownText(state: state)
                    .font(.system(.title, design: .rounded).monospacedDigit())
                    .fontWeight(.semibold)
                    .frame(maxWidth: 90, alignment: .trailing)
            }
            TimerBar(state: state)
        }
        .padding(16)
    }
}
