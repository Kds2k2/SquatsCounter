# Technical Specification: Refactor CreateCustomExerciseView

## Complexity Assessment
**Complexity Level**: Medium

**Rationale**: This refactor involves restructuring the navigation flow and UI presentation patterns, extracting components into a separate sheet, and managing state across view hierarchy. It requires careful handling of video player state, camera preview, and timing data while maintaining the existing functionality.

---

## Technical Context

**Language**: Swift/SwiftUI  
**Framework**: SwiftUI, AVFoundation, Vision  
**Deployment Target**: iOS (assumed based on UIKit references)  
**State Management**: @State, @StateObject, @Environment

**Dependencies**:
- SwiftUI for UI framework
- SwiftData for model persistence
- AVFoundation for video recording/playback
- Vision for pose detection

---

## Current Architecture

### Current Implementation Flow

1. **ExerciseListView** (`1. ExerciseListView.swift:79-94`)
   - Presents `CreateCustomExerciseView` as a **sheet**
   - Managed via `exerciseSheet` state with `.createPattern` case
   - User flow: AddExerciseView → CreateCustomExerciseView (both as sheets)

2. **CreateCustomExerciseView** (`3. CreateCustomExerciseView.swift:18-382`)
   - Contains entire creation flow in single view
   - Two states: `.recording` and `.reviewing`
   - **Recording state**: Shows camera preview + record button
   - **Reviewing state**: Shows video player, timeline, name input, angle buttons inline
   - Uses `onSave` callback closure to navigate back

### Current State Management

```swift
enum CreationState {
    case recording
    case reviewing
}
```

### Current UI Layout

**Recording View** (lines 84-139):
- Camera preview (FrontCameraPreviewView)
- Center record/stop button
- Recording indicator

**Reviewing View** (lines 141-182):
- Video player (50% of screen height)
- VideoTimelineView (timeline + Set Start/End buttons)
- TextField for pattern name
- All elements stacked vertically

---

## Required Changes

### 1. Navigation Pattern Change

**Current**: Sheet presentation  
**Target**: NavigationLink (full screen navigation)

**Changes Required**:
- Remove sheet presentation from `ExerciseListView`
- Add NavigationLink to `CreateCustomExerciseView`
- Update callback mechanism to use navigation dismiss instead of sheet dismiss

### 2. UI Restructuring

**Current**: Single view with conditional rendering  
**Target**: Main screen + Sheet for reviewing controls

**New Flow**:
1. User navigates to CreateCustomExerciseView screen (NavigationLink)
2. Screen shows:
   - Camera preview layer (full screen)
   - Start/Stop recording button overlay
3. When recording stops and state → `.reviewing`:
   - Camera preview switches to video player preview
   - **Automatically present a sheet** containing:
     - VideoTimelineView (timeline + angle selection buttons)
     - TextField for pattern name
     - Save/validation UI

### 3. Component Extraction

**New Component Required**: `PatternReviewSheet`
- Extract reviewing controls into separate sheet view
- Contains: VideoTimelineView, name TextField, Save button
- Receives bindings from parent for state synchronization

---

## Implementation Approach

### Files to Create

1. **`PatternReviewSheet.swift`** (new file)
   - Dedicated sheet view for pattern review controls
   - Input parameters:
     - `@Binding var name: String`
     - `@Binding var startTime: Double?`
     - `@Binding var endTime: Double?`
     - `@Binding var currentTime: Double`
     - `let videoURL: URL`
     - `let videoDuration: Double`
     - `let onSeek: (Double) -> Void`
     - `let onSave: () -> Void`
     - `let canSave: Bool`
   - Contains VideoTimelineView and name input UI

### Files to Modify

1. **`1. ExerciseListView.swift`**
   - Remove `.createPattern` case from `ExerciseSheet` enum (or keep for now to avoid breaking AddExerciseView)
   - Add `@State private var showCreatePattern = false`
   - Replace sheet presentation with NavigationLink
   - Update AddExerciseView's `onCreatePattern` callback to set `showCreatePattern = true`

   **Changes**:
   ```swift
   // Remove from sheet presentation
   case .createPattern:
       CreateCustomExerciseView { ... }
   
   // Add NavigationLink in toolbar or list
   NavigationLink(value: "createPattern", isActive: $showCreatePattern) {
       CreateCustomExerciseView(onSave: { ... })
   }
   ```

2. **`3. CreateCustomExerciseView.swift`**
   - Remove NavigationStack wrapper (parent handles navigation)
   - Add `@State private var showReviewSheet = false`
   - Modify `.onChange(of: recorderViewModel.recordedVideoURL)` to set `showReviewSheet = true`
   - Update `recordingView` to fill entire screen
   - Replace `reviewingView` inline content with video player only
   - Add `.sheet(isPresented: $showReviewSheet)` presenting PatternReviewSheet
   - Move timeline/name/buttons to PatternReviewSheet
   - Update toolbar to show on both states (Cancel always visible, Save when reviewing)

   **Key Changes**:
   - Line 72-77: Add `showReviewSheet = true` when video is ready
   - Lines 38-82: Remove NavigationStack, keep content only
   - Lines 141-182: Simplify to show only video player
   - Add sheet presentation with PatternReviewSheet

3. **`2. AddExerciseView.swift`**
   - Update `onCreatePattern` callback to trigger NavigationLink instead of sheet change
   - May need adjustment depending on navigation approach chosen

---

## Data Model / API / Interface Changes

### New View Interface

**PatternReviewSheet**:
```swift
struct PatternReviewSheet: View {
    @Binding var name: String
    @Binding var startTime: Double?
    @Binding var endTime: Double?
    @Binding var currentTime: Double
    
    let videoURL: URL
    let videoDuration: Double
    let onSeek: (Double) -> Void
    let onSave: () -> Void
    let canSave: Bool
    
    var body: some View { ... }
}
```

### Modified View Interfaces

**CreateCustomExerciseView**:
- Remove: NavigationStack wrapper
- Add: `@State private var showReviewSheet: Bool = false`
- Modify: `body` to return ZStack with camera/video + overlay controls
- Add: `.sheet(isPresented: $showReviewSheet)` modifier

**ExerciseListView**:
- Add: NavigationLink destination for CreateCustomExerciseView
- Modify: Remove `.createPattern` from sheet enum (or deprecate)
- Update: `onCreatePattern` callback mechanism

---

## Component Structure Changes

### Before
```
ExerciseListView
└── .sheet(exerciseSheet)
    ├── AddExerciseView
    └── CreateCustomExerciseView (entire flow as sheet)
        ├── NavigationStack
        │   ├── recordingView (camera + button)
        │   └── reviewingView (video + timeline + name + buttons)
        └── .toolbar
```

### After
```
ExerciseListView
├── .sheet(exerciseSheet)
│   └── AddExerciseView
└── NavigationLink
    └── CreateCustomExerciseView (full screen)
        ├── ZStack (always shown)
        │   ├── camera preview (when recording)
        │   ├── video player (when reviewing)
        │   └── record button overlay
        ├── .sheet(showReviewSheet)
        │   └── PatternReviewSheet
        │       ├── VideoTimelineView
        │       ├── TextField (name)
        │       └── Save button
        └── .toolbar (Cancel button)
```

---

## State Flow Changes

### Current
1. User taps "Create Custom Pattern" → Sheet opens
2. Recording starts → State = `.recording`
3. Recording stops → State = `.reviewing`, inline UI updates
4. User saves → Sheet dismisses

### New
1. User taps "Create Custom Pattern" → NavigationLink pushes screen
2. Screen shows camera preview + record button
3. Recording starts/stops → Video captured
4. State = `.reviewing` → Triggers `showReviewSheet = true`
5. Sheet presents with PatternReviewSheet
6. User configures in sheet, taps Save
7. Sheet dismisses, navigation pops back

---

## Verification Approach

### Manual Testing Checklist

1. **Navigation Flow**
   - [ ] Tapping "Create Custom Pattern" opens full screen (not sheet)
   - [ ] Cancel button returns to ExerciseListView
   - [ ] Back gesture works correctly

2. **Recording State**
   - [ ] Camera preview displays correctly
   - [ ] Record button is visible and functional
   - [ ] Recording indicator appears during recording
   - [ ] Stop button stops recording successfully

3. **Review State**
   - [ ] Video player replaces camera preview
   - [ ] Review sheet presents automatically after recording
   - [ ] Sheet contains timeline, name field, and angle buttons
   - [ ] Sheet can be dismissed and reopened

4. **State Synchronization**
   - [ ] Timeline updates reflect in video player
   - [ ] Start/End angle selections work correctly
   - [ ] Name input persists across sheet dismiss/present
   - [ ] Save button enables/disables based on validation

5. **Pattern Saving**
   - [ ] Save creates pattern successfully
   - [ ] Navigation returns to ExerciseListView after save
   - [ ] Video cleanup occurs properly
   - [ ] New pattern appears in AddExerciseView picker

### Automated Testing

- Run existing test suite (if any): Check README or `SquatsCounterTests/` for test commands
- Verify no regressions in ExerciseListView navigation
- Check memory leaks with Instruments (video player cleanup)

### Code Quality

- Run linter: Check for `swiftlint` or similar in project
- Build project: `xcodebuild` or Xcode build
- Check for warnings and deprecations

---

## Edge Cases & Considerations

1. **Sheet Dismissal**: User dismisses PatternReviewSheet without saving
   - Should they be able to re-open it?
   - Current approach: Yes, sheet can be re-presented

2. **Video Player State**: When sheet is dismissed/presented
   - Video should continue playing or pause?
   - Recommendation: Pause video when sheet appears, resume option available

3. **Camera Session Cleanup**: When navigating back during recording
   - Ensure camera session stops properly
   - Cleanup already handled in `.onDisappear` (line 78-80)

4. **Orientation**: How should video player handle device rotation?
   - Current code uses `imageGenerator.appliesPreferredTrackTransform = true`
   - Should maintain current behavior

5. **Navigation State**: User navigates back while reviewing
   - Should prompt to save changes?
   - Current: Cleanup and dismiss without save (line 52-55)
   - Recommendation: Add unsaved changes alert

---

## Risk Assessment

**Low Risk**:
- UI restructuring (extracting PatternReviewSheet)
- Sheet presentation logic

**Medium Risk**:
- Navigation pattern change (sheet → NavigationLink)
- State synchronization between parent and sheet
- Video player lifecycle during sheet transitions

**High Risk**:
- None identified

---

## Implementation Plan

Given the medium complexity, the implementation should be broken down into incremental steps:

1. **Create PatternReviewSheet component** with all reviewing controls
2. **Modify CreateCustomExerciseView** to use sheet presentation for review
3. **Update ExerciseListView** navigation to use NavigationLink
4. **Test state flow** and fix any synchronization issues
5. **Verify video player** behavior across sheet lifecycle
6. **Manual testing** of complete flow
7. **Code cleanup** and final verification

Each step should be tested incrementally before proceeding to the next.
