import ActivityKit
import Flutter
import Foundation

/// iOS half of the `yawa4u/live_card` channel: renders the rest timer as a
/// Live Activity on the Lock Screen and Dynamic Island.
///
/// Mirrors the Android promoted-notification implementation behind the same
/// channel and method names, so the Dart `LiveCard` API is platform-agnostic.
///
/// State travels in a typed `ContentState` through ActivityKit rather than
/// App Group UserDefaults, which is what keeps this free of an App Group
/// entitlement. A running rest costs zero updates: the extension renders the
/// countdown from `endDate`, so we only push on real transitions.
class LiveCardPlugin: NSObject {
    private static let channelName = "yawa4u/live_card"

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = LiveCardPlugin()
        channel.setMethodCallHandler(instance.handle)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 16.2, *) else {
            // Below 16.2 every method is a no-op; Dart falls back to nothing
            // on iOS (there is no notification-based equivalent).
            result(call.method == "isSupported" ? false : true)
            return
        }

        switch call.method {
        case "isSupported":
            result(ActivityAuthorizationInfo().areActivitiesEnabled)
        case "showCountdown":
            upsert(call, paused: false)
            result(true)
        case "showPaused":
            upsert(call, paused: true)
            result(true)
        case "cancel":
            end()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @available(iOS 16.2, *)
    private func upsert(_ call: FlutterMethodCall, paused: Bool) {
        guard let args = call.arguments as? [String: Any] else { return }

        let now = Date()
        let endDate: Date
        if let untilMs = args["untilMs"] as? NSNumber {
            endDate = Date(timeIntervalSince1970: untilMs.doubleValue / 1000.0)
        } else {
            endDate = now
        }
        let state = RestTimerAttributes.ContentState(
            exerciseName: args["title"] as? String ?? "",
            setLine: args["body"] as? String ?? "",
            endDate: endDate,
            startDate: now,
            isPaused: paused,
            pausedDisplay: args["pausedDisplay"] as? String ?? ""
        )

        // Update in place when one is already running so the card doesn't
        // flicker between sets; otherwise request a new one.
        if let existing = Activity<RestTimerAttributes>.activities.first {
            Task { await existing.update(using: state) }
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            NSLog("live_card: activities not enabled; skipping")
            return
        }
        do {
            let activity = try Activity.request(
                attributes: RestTimerAttributes(),
                contentState: state,
                pushType: nil
            )
            NSLog("live_card: started Live Activity \(activity.id)")
        } catch {
            NSLog("live_card: failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    @available(iOS 16.2, *)
    private func end() {
        // .immediate so a skipped rest disappears at once instead of
        // lingering on the Lock Screen for the system's default grace period.
        for activity in Activity<RestTimerAttributes>.activities {
            Task { await activity.end(dismissalPolicy: .immediate) }
        }
    }
}
