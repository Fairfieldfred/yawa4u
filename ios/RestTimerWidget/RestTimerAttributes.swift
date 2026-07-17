import ActivityKit
import Foundation

/// Shape of the rest-timer Live Activity.
///
/// Compiled into BOTH the Runner app (which starts/updates/ends the activity)
/// and the widget extension (which renders it), so the two agree on the
/// payload. Everything in `ContentState` travels through ActivityKit itself —
/// deliberately no App Group UserDefaults, which is what lets this ship
/// without an App Group entitlement or Developer portal changes.
///
/// Availability-gated: the Runner app still deploys to iOS 15.5, below
/// ActivityKit's 16.1 floor.
@available(iOS 16.1, *)
public struct RestTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Localized exercise name — the Dart side localizes before sending,
        /// because stored names are canonical English identity keys.
        public var exerciseName: String

        /// Pre-formatted "Next: set 2 of 4 · 80 kg × 8" line. Formatted in
        /// Dart so unit preference and locale stay in one place.
        public var setLine: String

        /// Wall-clock rest deadline. The extension renders the countdown from
        /// this with `Text(timerInterval:)`, so the OS ticks it and we never
        /// push a per-second update.
        public var endDate: Date

        /// Start of the current rest, for the progress bar's span.
        public var startDate: Date

        /// True while paused: the countdown freezes and shows remaining text.
        public var isPaused: Bool

        /// Pre-formatted "MM:SS" shown while paused (the timer view can't
        /// render a frozen value).
        public var pausedDisplay: String

        public init(
            exerciseName: String,
            setLine: String,
            endDate: Date,
            startDate: Date,
            isPaused: Bool,
            pausedDisplay: String
        ) {
            self.exerciseName = exerciseName
            self.setLine = setLine
            self.endDate = endDate
            self.startDate = startDate
            self.isPaused = isPaused
            self.pausedDisplay = pausedDisplay
        }
    }

    public init() {}
}
