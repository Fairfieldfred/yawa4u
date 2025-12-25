# WatchOS Companion App Build Plan for YAWA4U

## Project Overview

This document outlines the plan for building a WatchOS companion app for **YAWA4U** (Yet Another Workout App for You). The companion app will allow users to log exercise sets directly from their Apple Watch, with a swipe-based interface similar to the existing `exercises_screen.dart` implementation.

---

## 1. Technical Constraints & Considerations

### 1.1 Why WatchOS is Special for Flutter

**Flutter does NOT natively support WatchOS.** This creates unique challenges:

- ❌ Flutter cannot run directly on watchOS
- ❌ Flutter cannot use Apple's WatchConnectivity Framework directly
- ❌ WatchOS cannot interpret Flutter's Method Channels
- ✅ Solution: Build a **native Swift watchOS app** that communicates with Flutter through an iOS bridge

### 1.2 Three-Tier Communication Architecture

Based on the article's recommended approach, we need to implement:

```
┌─────────────────┐     MethodChannel     ┌─────────────────┐     WCSession      ┌─────────────────┐
│   Flutter App   │ ◄──────────────────► │  iOS Native     │ ◄────────────────► │   WatchOS App   │
│   (Dart)        │                       │  Layer (Swift)  │                    │   (Swift)       │
└─────────────────┘                       └─────────────────┘                    └─────────────────┘
```

**Key Insight:** The WatchOS app and Flutter app **cannot communicate directly**. The iOS native layer acts as the crucial bridge.

---

## 2. Project Structure

### 2.1 New Files to Create

#### Flutter/Dart Side

```
lib/
├── services/
│   └── watch_os_communication/
│       ├── watch_os_communication_service.dart      # Generic communication service
│       └── watch_os_communication_extension.dart    # YAWA4U-specific extensions
```

#### iOS Native Side (Runner)

```
ios/
├── Runner/
│   └── WatchOSCommunication/
│       ├── WatchConnectivityHandler.swift           # WCSession management
│       └── WatchOSMethodChannelHandler.swift        # Method channel handling
```

#### WatchOS App (New Target)

```
ios/
├── YAWAWatch Watch App/
│   ├── YAWAWatchApp.swift                          # App entry point
│   ├── ContentView.swift                           # Main view
│   ├── Views/
│   │   ├── ExerciseSetView.swift                   # Set logging interface
│   │   ├── ExerciseListView.swift                  # Exercise navigation
│   │   └── WorkoutSummaryView.swift                # Completion summary
│   ├── Models/
│   │   ├── WatchExercise.swift                     # Exercise model for watch
│   │   └── WatchExerciseSet.swift                  # Set model for watch
│   └── Services/
│       ├── CommunicationService.swift              # Generic WCSession service
│       └── WorkoutCommunicationManager.swift       # YAWA4U-specific messaging
```

---

## 3. Communication Layer Implementation

### 3.1 Phase 1: Generic Communication Service (Flutter/Dart)

Create a singleton service that handles all MethodChannel interactions:

```dart
// lib/services/watch_os_communication/watch_os_communication_service.dart

class WatchOSCommunicationService {
  // Singleton pattern
  factory WatchOSCommunicationService() => _instance;
  WatchOSCommunicationService._privateConstructor();
  static final WatchOSCommunicationService _instance =
      WatchOSCommunicationService._privateConstructor();

  // MethodChannel for iOS communication
  static const MethodChannel channel = MethodChannel('watchOS_communication');

  // Stream for watch reachability status
  final StreamController<bool> _reachabilityController =
      StreamController<bool>.broadcast();
  Stream<bool> get watchReachabilityStream => _reachabilityController.stream;

  // Core methods
  void initialize();
  Future<void> sendMessageToWatch(Map<String, dynamic> message);
  Future<Map<String, dynamic>?> sendMessageWithReply(Map<String, dynamic> message);
  Future<void> updateApplicationContext(Map<String, dynamic> context);
}
```

### 3.2 Phase 2: iOS Intermediary Layer

#### WatchConnectivityHandler.swift

- Manages WCSession lifecycle
- Handles message sending with retry logic
- Publishes reachability and message events

#### WatchOSMethodChannelHandler.swift

- Routes MethodChannel calls from Flutter
- Delegates to WatchConnectivityHandler
- Returns responses to Flutter

### 3.3 Phase 3: WatchOS Communication Service

```swift
// CommunicationService.swift (WatchOS)

class CommunicationService: NSObject, WCSessionDelegate {
    static let shared = CommunicationService()

    let reachabilityPublisher = PassthroughSubject<Bool, Never>()
    let receivedMessagePublisher = PassthroughSubject<[String: Any], Never>()

    func sendMessage(_ message: [String: Any],
                     maxRetries: Int = 3,
                     completion: @escaping (Result<[String: Any], Error>) -> Void)
}
```

---

## 4. YAWA4U-Specific Implementation

### 4.1 Data Models for Watch

Based on existing models in `lib/data/models/`:

```swift
// WatchExercise.swift
struct WatchExercise: Codable, Identifiable {
    let id: String
    let name: String
    let muscleGroup: String
    let equipmentType: String
    var sets: [WatchExerciseSet]
    let orderIndex: Int
}

// WatchExerciseSet.swift
struct WatchExerciseSet: Codable, Identifiable {
    let id: String
    let setNumber: Int
    var weight: Double?
    var reps: String
    let setType: String  // "regular", "myorep", "myorepMatch"
    var isLogged: Bool
    var isSkipped: Bool
}
```

### 4.2 Message Types

Define the communication protocol between Flutter and WatchOS:

| Action                  | Direction             | Payload                                |
| ----------------------- | --------------------- | -------------------------------------- |
| `requestCurrentWorkout` | Watch → iOS → Flutter | None                                   |
| `sendWorkoutData`       | Flutter → iOS → Watch | `{workout: {...}, exercises: [...]}`   |
| `logSet`                | Watch → iOS → Flutter | `{exerciseId, setIndex, weight, reps}` |
| `setLogged`             | Flutter → iOS → Watch | `{exerciseId, setIndex, success}`      |
| `skipSet`               | Watch → iOS → Flutter | `{exerciseId, setIndex}`               |
| `nextExercise`          | Watch → iOS → Flutter | `{currentExerciseId}`                  |
| `finishWorkout`         | Watch → iOS → Flutter | `{workoutId}`                          |
| `workoutSyncUpdate`     | Flutter → iOS → Watch | `{exercises: [...]}`                   |

### 4.3 Flutter Extension for YAWA4U

```dart
// watch_os_communication_extension.dart

extension WatchOSCommunicationServiceExtension on WatchOSCommunicationService {

  /// Handle incoming messages from WatchOS
  Future<Map<String, dynamic>?> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'receivedMessageFromWatch':
        return await _processWatchMessage(call.arguments);
      default:
        return null;
    }
  }

  /// Send current workout data to watch
  Future<void> sendWorkoutToWatch(Workout workout) async {
    final exercises = workout.exercises.map((e) => {
      'id': e.id,
      'name': e.name,
      'muscleGroup': e.muscleGroup.name,
      'equipmentType': e.equipmentType.name,
      'sets': e.sets.map((s) => {
        'id': s.id,
        'setNumber': s.setNumber,
        'weight': s.weight,
        'reps': s.reps,
        'setType': s.setType.name,
        'isLogged': s.isLogged,
        'isSkipped': s.isSkipped,
      }).toList(),
    }).toList();

    await sendMessageToWatch({
      'action': 'sendWorkoutData',
      'exercises': exercises,
    });
  }

  /// Handle set logging from watch
  Future<void> handleSetLogged(String exerciseId, int setIndex,
                                double? weight, String reps);

  /// Handle workout completion from watch
  Future<void> handleWorkoutFinished(String workoutId);
}
```

---

## 5. WatchOS UI Implementation

### 5.1 Main Exercise View (Swipe Interface)

Matching the behavior of `exercises_screen.dart`:

```swift
// ExerciseSetView.swift

struct ExerciseSetView: View {
    let exercise: WatchExercise
    @State private var currentSetIndex: Int = 0
    @ObservedObject var communicationManager: WorkoutCommunicationManager

    var body: some View {
        TabView(selection: $currentSetIndex) {
            ForEach(exercise.sets.indices, id: \.self) { index in
                SetLogView(set: exercise.sets[index], onLog: { weight, reps in
                    communicationManager.logSet(
                        exerciseId: exercise.id,
                        setIndex: index,
                        weight: weight,
                        reps: reps
                    )
                })
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}
```

### 5.2 Set Logging View

```swift
// SetLogView.swift

struct SetLogView: View {
    let set: WatchExerciseSet
    let onLog: (Double?, String) -> Void

    @State private var weight: Double?
    @State private var reps: String = ""

    var body: some View {
        VStack(spacing: 8) {
            // Set number indicator
            Text("Set \(set.setNumber)")
                .font(.headline)

            // Weight input (Digital Crown)
            HStack {
                Text("Weight:")
                Text("\(weight ?? 0, specifier: "%.1f") lbs")
            }
            .focusable()
            .digitalCrownRotation($weight, from: 0, through: 500, by: 2.5)

            // Reps picker
            Picker("Reps", selection: $reps) {
                ForEach(["5", "6", "7", "8", "9", "10", "11", "12", "2 RIR", "1 RIR", "0 RIR"], id: \.self) {
                    Text($0)
                }
            }

            // Log button
            Button(action: { onLog(weight, reps) }) {
                Image(systemName: set.isLogged ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(set.isLogged ? .green : .primary)
            }
        }
    }
}
```

### 5.3 Exercise Navigation

```swift
// ExerciseListView.swift

struct ExerciseListView: View {
    @ObservedObject var communicationManager: WorkoutCommunicationManager
    @State private var currentExerciseIndex: Int = 0

    var body: some View {
        TabView(selection: $currentExerciseIndex) {
            ForEach(communicationManager.exercises.indices, id: \.self) { index in
                ExerciseSetView(
                    exercise: communicationManager.exercises[index],
                    communicationManager: communicationManager
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        // Swipe between exercises (horizontal)
    }
}
```

---

## 6. Xcode Project Configuration

### 6.1 Adding WatchOS Target

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → watchOS → App
3. Name: `YAWAWatch`
4. Interface: SwiftUI
5. Language: Swift
6. Include Notification Scene: No (initially)

### 6.2 App Group Configuration

Both iOS app and WatchOS app need to share an App Group for data persistence:

1. Add capability "App Groups" to Runner target
2. Add capability "App Groups" to YAWAWatch target
3. Create group: `group.com.yourcompany.yawa4u`

### 6.3 Build Settings

| Setting                   | Value        |
| ------------------------- | ------------ |
| Deployment Target (Watch) | watchOS 9.0+ |
| Swift Version             | 5.9          |
| Enable Bitcode            | No           |

---

## 7. Implementation Phases

### Phase 1: Foundation (Week 1-2) ✅ COMPLETED

- [x] Create WatchOS target in Xcode
- [x] Implement generic `WatchOSCommunicationService` in Dart
- [x] Implement `WatchConnectivityHandler` in iOS Runner
- [x] Implement `WatchOSMethodChannelHandler` in iOS Runner
- [x] Implement `CommunicationService` in WatchOS
- [x] Test basic message passing between Flutter ↔ iOS ↔ WatchOS
- [x] Configure Watch app embedding in Runner target (Build Phases)
- [x] Verify `isWatchAppInstalled = true` on physical devices

**Completed: December 24, 2025**
**Notes:** Communication uses applicationContext for reliable delivery. Real devices required for full testing.

### Phase 2: Data Synchronization (Week 3) 🔄 IN PROGRESS

- [x] Define YAWA4U-specific message protocol
- [x] Implement `WatchOSCommunicationExtension` in Dart
- [x] Implement `WorkoutCommunicationManager` in WatchOS
- [x] Create WatchOS data models (`WatchExercise`, `WatchExerciseSet`, `WatchWorkout`)
- [ ] Add new Swift files to Xcode project (Models folder)
- [ ] Test workout data syncing

**Files Created:**

- `lib/data/services/watch_os_communication_extension.dart` - Dart extension with workout-specific methods
- `ios/yawa4u Watch App/Models/WatchExercise.swift` - Exercise model for Watch
- `ios/yawa4u Watch App/Models/WatchExerciseSet.swift` - ExerciseSet model for Watch
- `ios/yawa4u Watch App/Models/WatchWorkout.swift` - Workout container model
- `ios/yawa4u Watch App/Services/WorkoutCommunicationManager.swift` - Watch-side workout messaging

### Phase 3: WatchOS UI (Week 4-5)

- [ ] Create `ExerciseListView` with swipe navigation
- [ ] Create `ExerciseSetView` with set-by-set interface
- [ ] Create `SetLogView` with Digital Crown input (in ExerciseSetView.swift)
- [ ] Implement logging confirmation haptics
- [ ] Create `WorkoutSummaryView`

### Phase 4: Integration (Week 6)

- [ ] Connect watch UI to communication manager
- [ ] Handle real-time sync between phone and watch
- [ ] Implement offline handling (queue messages when disconnected)
- [ ] Handle app state changes (background/foreground)

### Phase 5: Polish & Testing (Week 7-8)

- [ ] Add workout completion flow
- [ ] Implement error handling and retry logic
- [ ] Test on physical Apple Watch devices
- [ ] Add complications (optional)
- [ ] Performance optimization

---

## 8. Key Reference Files from YAWA4U

When implementing, reference these existing files:

| Purpose            | File                                             |
| ------------------ | ------------------------------------------------ |
| Exercise model     | `lib/data/models/exercise.dart`                  |
| ExerciseSet model  | `lib/data/models/exercise_set.dart`              |
| Swipe UI pattern   | `lib/presentation/screens/exercises_screen.dart` |
| Set types (enum)   | `lib/core/constants/enums.dart`                  |
| Workout repository | `lib/data/repositories/workout_repository.dart`  |

---

## 9. External Resources

### Reference Implementation

- **Contact Abyss Example Project**: [GitHub Repository](https://github.com/Toglefritz/Contact_Abyss)
  - Generic communication service (Dart): `lib/services/watch_os_communication/watch_os_communication_service.dart`
  - iOS handler: `ios/Runner/PlatformChannels/WatchOSCommunication/`
  - WatchOS service: `ios/WatchApp Watch App/Services/CommunicationService.swift`

### Apple Documentation

- [WatchConnectivity Framework](https://developer.apple.com/documentation/watchconnectivity)
- [SwiftUI for watchOS](https://developer.apple.com/documentation/watchos-apps)

### Flutter Documentation

- [Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

---

## 10. Testing Strategy

### Unit Tests

- Test message serialization/deserialization
- Test communication service initialization
- Test retry logic in Swift

### Integration Tests

- Test Flutter → iOS → WatchOS message flow
- Test WatchOS → iOS → Flutter message flow
- Test offline queuing and reconnection

### Device Testing

- Test on Apple Watch Series 6+ (watchOS 9+)
- Test with iPhone in different states (foreground, background, killed)
- Test with poor Bluetooth connectivity

---

## 11. Future Enhancements

- **Complications**: Show current exercise or workout progress on watch face
- **Notifications**: Alert user when rest timer completes
- **Standalone Mode**: Allow basic logging without iPhone connection
- **Voice Input**: Use Siri for rep/weight input
- **Heart Rate Integration**: Log heart rate with sets
- **HealthKit Sync**: Write workouts to Apple Health

---

## Summary

Building a WatchOS companion for a Flutter app requires:

1. **Native Swift Development** for the actual WatchOS app
2. **Three-Tier Architecture** with iOS as the communication bridge
3. **Platform Channels** to connect Dart code to native iOS code
4. **WatchConnectivity Framework** for iOS ↔ WatchOS communication

The key insight is that Flutter never touches WatchOS directly—the iOS native layer is the essential intermediary that makes cross-platform communication possible.

---

_Document Version: 1.0_  
_Created: December 22, 2025_  
_Based on: "Building a WatchOS Companion App for Flutter" by Scott Hatfield_
