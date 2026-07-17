import SwiftUI
import WidgetKit

/// Entry point for the widget extension.
///
/// Live Activities need iOS 16.2 in practice (16.1 shipped the API but the
/// Simulator only supports them from 16.2), so the bundle stays empty below
/// that rather than failing to build.
@main
struct RestTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.2, *) {
            RestTimerLiveActivity()
        }
    }
}
