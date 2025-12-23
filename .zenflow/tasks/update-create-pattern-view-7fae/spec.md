# Technical Specification: Update CreatePatternView

## Task Complexity Assessment
**Difficulty**: Medium

This task involves multiple UI/UX fixes and refactoring with moderate complexity. It requires:
- File renaming and navigation updates
- Understanding SwiftUI navigation and tab bar behavior
- State management for sheet persistence
- Integrating real-time pose detection with video playback

## Technical Context

### Language & Framework
- **Language**: Swift
- **Framework**: SwiftUI
- **Dependencies**: 
  - AVFoundation (video recording/playback)
  - Vision framework (pose detection)
  - SwiftData (model persistence)

### Key Components
- **VideoRecorderViewModel**: Manages camera session and video recording
- **PoseEstimator**: Real-time pose detection during live camera feed
- **StickFigureView**: Visual overlay for detected body parts
- **PatternReviewSheet**: Bottom sheet for pattern configuration

## Current Architecture

### File Structure
```
SquatsCounter/Views/Exercise/
├── 1. ExerciseListView.swift          # Entry point, shows list of exercises
├── 2. ExerciseView.swift              # Individual exercise execution view
├── 3. CreateCustomExerciseView.swift  # Pattern creation (TO BE RENAMED)
├── PatternReviewSheet.swift           # Configuration sheet
├── VideoRecorderViewModel.swift       # Recording logic
└── VideoTimelineView.swift            # Timeline UI component

SquatsCounter/Views/StickVigure/
├── StickFigureView.swift              # Pose visualization
└── Stick.swift                        # Drawing component

SquatsCounter/Managers/
└── PoseEstimator.swift                # Pose detection logic
```

### Navigation Flow
1. **ContentView** → TabView with 3 tabs (Exercises, Jogging, Routes)
2. **ExerciseListView** (Tab 1) → `.sheet` → **AddExerciseView**
3. **AddExerciseView** → triggers `.navigationDestination` → **CreateCustomExerciseView**
4. **CreateCustomExerciseView** → two states: recording & reviewing

### Current Issues

#### Issue 1: Naming Convention
- File is named `CreateCustomExerciseView` but creates patterns, not exercises
- Should be renamed to `CreatePatternView` for clarity

#### Issue 2: Tab Bar Visibility
- **Root cause**: Using `.navigationDestination` navigation doesn't automatically hide tab bar
- **Location**: ExerciseListView.swift:83-87
- **Current code**:
```swift
.navigationDestination(isPresented: $showCreatePattern) {
    CreateCustomExerciseView {
        showCreatePattern = false
    }
}
```
- **Problem**: Tab bar remains visible when navigating to CreateCustomExerciseView

#### Issue 3: Sheet Persistence
- **Root cause**: Sheet is dismissed but cannot be reopened
- **Location**: CreateCustomExerciseView.swift:71-98
- **Current behavior**: 
  - `showReviewSheet` is set to `false` when sheet is dismissed
  - No UI control exists to reopen the sheet after dismissal
  - User loses access to pattern configuration
- **Expected**: Sheet should be reopenable via a button/control when in reviewing state

#### Issue 4: Missing StickFigure Visualization
- **Root cause**: StickFigureView not integrated in reviewing state
- **Location**: CreateCustomExerciseView.swift:161-170 (reviewingView)
- **Requirements**:
  - NOT needed during recording (recording UI is clean)
  - MUST be present during reviewing to verify pose detection quality
  - Should overlay on VideoPlayerView similar to ExerciseView.swift:48-56
- **Technical challenge**: 
  - PoseEstimator works with live camera feed (AVCaptureVideoDataOutputSampleBufferDelegate)
  - Need to detect poses from video frames during playback
  - Must sync pose detection with video currentTime

## Implementation Approach

### 1. Rename CreateCustomExerciseView → CreatePatternView

**Files to modify:**
- Rename: `SquatsCounter/Views/Exercise/3. CreateCustomExerciseView.swift` → `3. CreatePatternView.swift`
- Update references in:
  - `ExerciseListView.swift` (import/usage)
  - Xcode project file (if necessary for build configuration)

**Code changes:**
```swift
// Old
struct CreateCustomExerciseView: View { ... }

// New
struct CreatePatternView: View { ... }
```

### 2. Fix Tab Bar Visibility

**Approach**: Add `.toolbar(.hidden, for: .tabBar)` modifier to CreatePatternView

**Location**: CreatePatternView.swift:39-102 (body property)

**Implementation**:
```swift
var body: some View {
    ZStack {
        // ... existing content
    }
    .toolbar(.hidden, for: .tabBar)  // ADD THIS
    .ignoresSafeArea()
    .navigationTitle("Create Custom Pattern")
    // ... rest of modifiers
}
```

**Rationale**: SwiftUI's `.toolbar(.hidden, for: .tabBar)` modifier is the recommended way to hide tab bars in navigation destinations, matching the pattern used in ExerciseView.swift:40.

### 3. Fix Sheet Persistence

**Approach**: Add a floating button to reopen the sheet when in reviewing state

**State management changes:**
- Keep `showReviewSheet` as the sheet presentation controller
- Add button in `reviewingView` to toggle `showReviewSheet = true`

**UI Design**:
- Floating action button in top-right corner during reviewing
- System icon: "slider.horizontal.3" (represents configuration/settings)
- Style: Consistent with recording button aesthetics

**Implementation**:
```swift
private var reviewingView: some View {
    ZStack {
        if let player = player {
            VideoPlayerView(player: player)
        } else {
            Rectangle()
                .fill(Color.black)
        }
        
        // ADD: Floating button to reopen sheet
        VStack {
            HStack {
                Spacer()
                Button {
                    showReviewSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding()
            }
            Spacer()
        }
    }
}
```

### 4. Add StickFigure During Reviewing

**Challenge**: PoseEstimator is designed for real-time camera feed, not video playback

**Solution Strategy**:
1. Create a separate pose detection mechanism for video frames
2. Extract pose at current playback time
3. Display StickFigureView overlay with detected pose
4. Update pose when video time changes

**Technical Implementation**:

#### Option A: Real-time pose detection during playback (Preferred)
- Use the existing time observer (CreatePatternView.swift:205-207)
- Extract frame at current time
- Run Vision pose detection
- Update bodyParts state for StickFigureView

**New state variables:**
```swift
@State private var reviewBodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
@State private var lastProcessedTime: Double = 0
```

**Modified reviewingView:**
```swift
private var reviewingView: some View {
    ZStack {
        if let player = player {
            GeometryReader { geo in
                VideoPlayerView(player: player)
                
                // ADD: StickFigure overlay
                if !reviewBodyParts.isEmpty {
                    StickFigureView(bodyParts: reviewBodyParts, size: geo.size)
                }
            }
        } else {
            Rectangle().fill(Color.black)
        }
        
        // ... sheet reopen button
    }
    .onChange(of: currentTime) { _, newTime in
        // Throttle processing to ~10 FPS
        if abs(newTime - lastProcessedTime) > 0.1 {
            Task {
                await updateReviewPose(at: newTime)
            }
        }
    }
}
```

**Helper function:**
```swift
private func updateReviewPose(at time: Double) async {
    guard let videoURL = recorderViewModel.recordedVideoURL else { return }
    
    do {
        let bodyParts = try await extractPoseFromVideo(url: videoURL, at: time)
        await MainActor.run {
            reviewBodyParts = bodyParts
            lastProcessedTime = time
        }
    } catch {
        print("Failed to detect pose at time \(time): \(error)")
        await MainActor.run {
            reviewBodyParts = [:]
        }
    }
}

private func extractPoseFromVideo(url: URL, at time: Double) async throws -> [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    imageGenerator.requestedTimeToleranceBefore = .zero
    imageGenerator.requestedTimeToleranceAfter = .zero
    
    let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    let cgImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
    
    return try await detectPose(in: cgImage)
}
```

**Note**: The `detectPose(in:)` function already exists at line 310-338, can be reused.

#### StickFigureView Modification

**Current issue**: StickFigureView expects a PoseEstimator (@ObservedObject)

**Location**: StickFigureView.swift:10-18

**Current signature:**
```swift
struct StickFigureView: View {
    @ObservedObject var postEstimator: PoseEstimator
    var size: CGSize
```

**Required change**: Make it accept bodyParts directly for reusability

**New implementation:**
```swift
struct StickFigureView: View {
    var bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    var size: CGSize
    
    var body: some View {
        if !bodyParts.isEmpty {
            fullBodyView()
        }
    }
    
    private func fullBodyView() -> some View {
        // ... existing drawing logic using bodyParts
    }
}

// Add convenience initializer for backwards compatibility
extension StickFigureView {
    init(postEstimator: PoseEstimator, size: CGSize) {
        self.bodyParts = postEstimator.bodyParts
        self.size = size
    }
}
```

**Impact**: ExerciseView.swift:54 will need minor update to pass bodyParts directly or use the convenience initializer.

## Source Code Structure Changes

### Files to Create
- None

### Files to Rename
1. `SquatsCounter/Views/Exercise/3. CreateCustomExerciseView.swift` → `3. CreatePatternView.swift`

### Files to Modify
1. **SquatsCounter/Views/Exercise/3. CreatePatternView.swift** (renamed)
   - Rename struct and update all internal references
   - Add `.toolbar(.hidden, for: .tabBar)` modifier
   - Add sheet reopen button in reviewingView
   - Add state variables for review pose detection
   - Add StickFigureView overlay in reviewingView
   - Add pose extraction logic for video playback
   - Add onChange handler for currentTime to trigger pose updates

2. **SquatsCounter/Views/Exercise/1. ExerciseListView.swift**
   - Update import/reference from CreateCustomExerciseView to CreatePatternView
   - Line 84: Update struct name in navigationDestination

3. **SquatsCounter/Views/StickVigure/StickFigureView.swift**
   - Refactor to accept bodyParts dictionary instead of PoseEstimator
   - Add convenience initializer for backwards compatibility

4. **SquatsCounter/Views/Exercise/2. ExerciseView.swift**
   - Update StickFigureView usage to use convenience initializer (minor change)

## Data Model / API / Interface Changes

### StickFigureView API Change
**Before:**
```swift
StickFigureView(postEstimator: poseEstimator, size: geo.size)
```

**After:**
```swift
// Option 1: Direct bodyParts
StickFigureView(bodyParts: bodyPartsDict, size: geo.size)

// Option 2: PoseEstimator (via convenience initializer)
StickFigureView(postEstimator: poseEstimator, size: geo.size)
```

**Rationale**: Decouples StickFigureView from PoseEstimator, making it reusable in contexts where we have bodyParts but no live PoseEstimator instance.

## Verification Approach

### Manual Testing Steps
1. **Test Rename & Tab Bar**
   - Navigate from ExerciseListView → "Create Pattern" option
   - Verify tab bar is hidden in CreatePatternView
   - Verify navigation title shows "Create Custom Pattern"

2. **Test Recording Flow**
   - Start recording in CreatePatternView
   - Record a simple movement (e.g., arm raise)
   - Stop recording
   - Verify transition to reviewing state

3. **Test Sheet Persistence**
   - In reviewing state, open PatternReviewSheet
   - Close sheet using drag gesture or tap outside
   - Verify floating button appears in top-right
   - Tap button and verify sheet reopens
   - Verify all state (name, startTime, endTime) is preserved

4. **Test StickFigure During Review**
   - While reviewing video, verify StickFigure overlay appears
   - Play/scrub through video timeline
   - Verify StickFigure updates to show detected pose at current time
   - Test with different poses (arms up, squat position, etc.)
   - Verify StickFigure handles missing body parts gracefully

5. **Test Pattern Creation**
   - Set pattern name
   - Mark start time (with visible pose)
   - Mark end time (with different visible pose)
   - Save pattern
   - Verify pattern saved to database
   - Return to ExerciseListView and verify pattern appears

### Build Verification
Since this is an iOS/Xcode project:
```bash
# Build command (if using xcodebuild)
xcodebuild -project SquatsCounter.xcodeproj -scheme SquatsCounter -configuration Debug clean build

# Or simply build in Xcode IDE
# Product → Build (⌘B)
```

### Lint/Type Checking
Swift projects typically don't have separate lint commands unless SwiftLint is configured. Check:
```bash
# Check for SwiftLint configuration
ls -la | grep swiftlint
cat .swiftlint.yml 2>/dev/null

# Run SwiftLint if available
swiftlint lint
```

No specific test framework is visible in the codebase. The SquatsCounterTests directory exists but appears to have minimal tests.

## Risk Assessment

### Low Risk
- Renaming files (straightforward refactor)
- Adding tab bar hide modifier (standard SwiftUI pattern)

### Medium Risk
- Sheet persistence UI/UX (needs careful state management)
- Real-time pose detection during video playback (performance considerations)

### Mitigation Strategies
- **Performance**: Throttle pose detection to ~10 FPS during review (0.1s intervals)
- **Error handling**: Gracefully handle missing body parts in StickFigureView
- **Testing**: Thoroughly test with various video lengths and poses

## Implementation Checklist

- [ ] Rename CreateCustomExerciseView → CreatePatternView
- [ ] Update all references in ExerciseListView
- [ ] Add `.toolbar(.hidden, for: .tabBar)` modifier
- [ ] Refactor StickFigureView to accept bodyParts
- [ ] Update ExerciseView to use refactored StickFigureView
- [ ] Add sheet reopen button in reviewingView
- [ ] Implement pose extraction from video frames
- [ ] Add StickFigureView overlay in reviewingView
- [ ] Add onChange handler for pose updates
- [ ] Test all functionality manually
- [ ] Build and verify no compilation errors
