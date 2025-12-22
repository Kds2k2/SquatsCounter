# Technical Specification: Custom Exercise Creation View

## Task Complexity
**Medium** - Requires camera integration, pose detection, and UI state management with some architectural considerations for ExerciseType extensions.

## Technical Context

### Language & Framework
- **Language**: Swift 5.x
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Computer Vision**: Vision framework (VNHumanBodyPoseObservation)
- **Camera**: AVFoundation

### Dependencies
- Vision framework for body pose detection
- AVFoundation for camera capture
- SwiftData for data persistence
- Existing `PoseEstimator` class for angle calculations

## Current Architecture

### Data Models
The app already has the foundation for custom exercises:

**ExerciseType** (`SquatsCounter/Models/Exercises/ExerciseType.swift:10-52`)
- Enum with cases: `.pushUps`, `.squating`, `.custom(CustomExercise)`
- Missing: `CaseIterable` conformance and `rawValue` computed property extensions

**CustomExercise** (`SquatsCounter/Models/Exercises/ExerciseType.swift:39-44`)
```swift
struct CustomExercise: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var startState: Angles
    var endState: Angles
}
```

**Angles** (`SquatsCounter/Models/Exercises/ExerciseType.swift:46-51`)
```swift
struct Angles: Codable, Equatable {
    var leftHand: CGFloat
    var rightHand: CGFloat
    var leftLeg: CGFloat
    var rightLeg: CGFloat
}
```

**Exercise** (`SquatsCounter/Models/Exercises/Exercise.swift:12-33`)
- SwiftData model with properties: name, type, count, requiredCount, isStart, isDone
- Already supports custom exercise types

### Existing Components

**PoseEstimator** (`SquatsCounter/Managers/PoseEstimator.swift`)
- Detects body poses using Vision framework
- Calculates angles between body joints via `calculateAngel()` method
- Already supports custom exercise counting logic (`:132-202`)
- Publishes `bodyParts` dictionary with recognized points

**FrontCameraView** (`SquatsCounter/Views/FrontCamera/FrontCameraView.swift`)
- Provides live camera preview using AVFoundation
- Integrates with PoseEstimator for real-time pose detection
- Uses `FrontContentViewModel` for camera session management

**AddExerciseView** (`SquatsCounter/Views/Exercise/AddExerciseView.swift`)
- Current interface for adding pre-defined exercises
- Uses sheet presentation with 160pt height
- Only supports `.pushUps` and `.squating` types

## Implementation Approach

### 1. ExerciseType Extensions
Create extension to support UI requirements:

**File**: `SquatsCounter/Extensions/ExerciseType+Extensions.swift` (new)
- Add `CaseIterable` conformance with static property for base cases
- Add `rawValue` computed property for display names
- Handle custom exercise name extraction

### 2. Custom Exercise Creation View
Create new view for custom exercise creation:

**File**: `SquatsCounter/Views/Exercise/CreateCustomExerciseView.swift` (new)

**State Management**:
- Exercise name input
- Repeat count selection
- Recording state (idle, recording, reviewing)
- Captured angles for start and end states
- PoseEstimator instance for real-time angle detection

**UI Components**:
1. **Camera Preview Section**: Full-screen camera with StickFigureView overlay
2. **Angle Capture Controls**: 
   - "Capture Start Position" button
   - "Capture End Position" button
   - Visual feedback showing captured angles
3. **Exercise Details Form**:
   - Name text field
   - Repeat count picker
4. **Save/Cancel Actions**

**Workflow**:
1. User opens camera preview
2. User positions body in start pose, taps "Capture Start Position"
3. System captures current angles (leftHand, rightHand, leftLeg, rightLeg)
4. User positions body in end pose, taps "Capture End Position"
5. System captures end angles
6. User fills in name and count
7. System creates CustomExercise and saves Exercise to SwiftData

### 3. Integration Points

**AddExerciseView Modification** (`SquatsCounter/Views/Exercise/AddExerciseView.swift`)
- Add navigation link or button to open CreateCustomExerciseView
- Option 1: Add "Create Custom Exercise" button alongside existing form
- Option 2: Replace current picker with segmented control (Predefined/Custom)

**ExerciseListView** (`SquatsCounter/Views/Exercise/ExerciseListView.swift:26-42`)
- Already handles custom exercises in the list grouping
- Should display custom exercise name from ExerciseType extension

## Source Code Structure Changes

### New Files
1. `SquatsCounter/Extensions/ExerciseType+Extensions.swift`
   - ExerciseType.allCases static property
   - ExerciseType.rawValue computed property

2. `SquatsCounter/Views/Exercise/CreateCustomExerciseView.swift`
   - Main view for custom exercise creation
   - Camera preview with angle capture UI
   - Form for exercise details
   - Save/cancel logic

### Modified Files
1. `SquatsCounter/Views/Exercise/AddExerciseView.swift`
   - Add button/navigation to CreateCustomExerciseView
   - Possibly update layout to accommodate new option

## Data Model Changes

No database schema changes required - the CustomExercise structure already exists and is fully compatible with the SwiftData Exercise model.

**New Exercise Creation Flow**:
```swift
let customExercise = CustomExercise(
    startState: capturedStartAngles,
    endState: capturedEndAngles
)
let exercise = Exercise(
    name: userProvidedName,
    type: .custom(customExercise),
    requiredCount: userSelectedCount
)
modelContext.insert(exercise)
```

## API/Interface Changes

### ExerciseType Extension Protocol
```swift
extension ExerciseType: CaseIterable {
    static var allCases: [ExerciseType] {
        [.pushUps, .squating]
    }
    
    var rawValue: String {
        switch self {
        case .pushUps: return "Push-ups"
        case .squating: return "Squats"
        case .custom: return "Custom Exercise"
        }
    }
}
```

Note: `allCases` excludes custom type since custom exercises are user-created instances, not static cases.

## Camera & Pose Detection Integration

**Angle Capture Logic**:
- Reuse existing `PoseEstimator.calculateAngel()` method
- Subscribe to `PoseEstimator.$bodyParts` publisher
- On "Capture" button tap, read current bodyParts and calculate all 4 angles:
  - Left hand: shoulder-elbow-wrist
  - Right hand: shoulder-elbow-wrist
  - Left leg: hip-knee-ankle
  - Right leg: hip-knee-ankle

**UI Feedback**:
- Show live angle values during capture
- Display StickFigureView overlay for body position reference
- Confirm visual/haptic feedback on successful capture

## Verification Approach

### Unit Testing
- Test ExerciseType.rawValue for all cases
- Test Angles equality and codability
- Test CustomExercise creation with valid angles

### Integration Testing
1. Create custom exercise through UI
2. Verify exercise appears in ExerciseListView
3. Start custom exercise and verify PoseEstimator counts correctly
4. Verify persistence after app restart

### Manual Testing Checklist
- [ ] Camera preview displays correctly
- [ ] Pose detection shows real-time stick figure
- [ ] Start position capture works and displays values
- [ ] End position capture works and displays values
- [ ] Name and count inputs work
- [ ] Save creates exercise in database
- [ ] Custom exercise appears in exercise list
- [ ] Custom exercise execution counts reps correctly
- [ ] Cancel discards creation properly

### Build & Lint Commands
```bash
# Build project
xcodebuild -scheme SquatsCounter -destination 'platform=iOS Simulator,name=iPhone 15' clean build

# Run tests  
xcodebuild test -scheme SquatsCounter -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Edge Cases & Considerations

1. **Invalid Pose Detection**: If body parts not detected, disable capture buttons
2. **Angle Validation**: Ensure captured angles are reasonable (0-180 degrees)
3. **Duplicate Angles**: Warn if start and end states are too similar
4. **Camera Permissions**: Handle denied camera access gracefully
5. **Memory Management**: Properly manage PoseEstimator lifecycle
6. **SwiftData Conflicts**: Handle concurrent modifications if needed

## Success Criteria

- [ ] User can open custom exercise creation view
- [ ] User can see live camera feed with pose overlay
- [ ] User can capture start position angles
- [ ] User can capture end position angles
- [ ] User can name the exercise
- [ ] User can set repeat count
- [ ] Custom exercise saves to SwiftData
- [ ] Custom exercise appears in list
- [ ] Custom exercise executes and counts reps correctly
- [ ] Build completes without errors
- [ ] No compiler warnings introduced
