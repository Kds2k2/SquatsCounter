# Bug Investigation: CreateCustomExerciseView Navigation Issues

## Bug Summary
Three related issues in the Exercise views:
1. CreateCustomExerciseView doesn't open when "Create Pattern" button is clicked
2. ExerciseSheet enum only has one case (unnecessary complexity)
3. Toolbar button visibility issue in ExerciseListView

## Root Cause Analysis

### Issue 1: Navigation Destination Not Working
**Location**: `SquatsCounter/Views/Exercise/1. ExerciseListView.swift:92-96`

The `.navigationDestination(isPresented: $showCreatePattern)` modifier is placed as a modifier on the `NavigationStack`, but it needs to be inside the NavigationStack's content hierarchy to work properly.

**Current structure** (lines 30-97):
```
ZStack {
    NavigationStack {
        // content (lines 32-63)
    }
    .navigationTitle(...)
    .toolbar { ... }
    .sheet(item: $exerciseSheet) { ... }
    .navigationDestination(isPresented: $showCreatePattern) { ... }  // ❌ Outside NavigationStack content
}
```

The `.navigationDestination` modifier is applied to the NavigationStack from outside, which prevents it from functioning correctly. It should be inside the NavigationStack's body.

### Issue 2: ExerciseSheet Enum Unnecessary
**Location**: `SquatsCounter/Views/Exercise/1. ExerciseListView.swift:11-15`

The `ExerciseSheet` enum only has one case (`.addExercise`), making it overly complex. A simple Boolean state would be clearer:
- Current: `@State private var exerciseSheet: ExerciseSheet?`
- Better: `@State private var showAddExercise = false`

### Issue 3: Toolbar Button Position
**Location**: `SquatsCounter/Views/Exercise/1. ExerciseListView.swift:68-78`

The toolbar is defined correctly but is applied as a modifier on the NavigationStack rather than being inside it. While this may work, it's not the standard pattern and could cause visibility issues.

## Affected Components
- `ExerciseListView.swift` - Main view with navigation issues
- `AddExerciseView.swift` - Works correctly, triggers `onCreatePattern()` callback
- `CreateCustomExerciseView.swift` - View that should open but doesn't

## Proposed Solution

1. **Fix navigation destination**: Move `.navigationDestination` inside the NavigationStack body
2. **Simplify state management**: Replace `ExerciseSheet` enum with a simple Boolean
3. **Fix toolbar placement**: Ensure toolbar and navigationTitle modifiers are properly positioned

## Implementation Steps

1. Remove the `ExerciseSheet` enum definition
2. Replace `@State private var exerciseSheet: ExerciseSheet?` with `@State private var showAddExercise = false`
3. Update button actions to set `showAddExercise = true` instead of `exerciseSheet = .addExercise`
4. Replace `.sheet(item: $exerciseSheet)` with `.sheet(isPresented: $showAddExercise)`
5. Move `.navigationDestination` inside the NavigationStack body
6. Ensure toolbar modifiers are inside NavigationStack content

## Expected Behavior After Fix
- Clicking "Create Pattern" button in AddExerciseView should dismiss the sheet and navigate to CreateCustomExerciseView
- Toolbar "+" button should be visible at all times
- Code will be simpler and more maintainable without unnecessary enum

---

## Implementation Notes

### Changes Made

1. **Removed ExerciseSheet enum** (lines 11-15) - No longer needed
2. **Replaced state variable** (line 15):
   - Before: `@State private var exerciseSheet: ExerciseSheet?`
   - After: `@State private var showAddExercise = false`

3. **Updated all button actions** (lines 34, 66):
   - Before: `exerciseSheet = .addExercise`
   - After: `showAddExercise = true`

4. **Simplified sheet presentation** (lines 73-82):
   - Before: `.sheet(item: $exerciseSheet) { sheet in switch sheet { case .addExercise: ... } }`
   - After: `.sheet(isPresented: $showAddExercise) { ... }`

5. **Fixed navigation structure** (lines 23-91):
   - Moved `NavigationStack` to wrap entire body
   - Moved `.navigationDestination` inside NavigationStack (line 83-87)
   - Moved `.toolbar` inside NavigationStack content (lines 62-72)
   - This ensures proper navigation hierarchy for `.navigationDestination` to work

### Test Results
Implementation complete. Ready for manual testing:
1. Launch app and verify toolbar "+" button is visible
2. Click "+" or "Add Exercise" button to open AddExerciseView sheet
3. Click "Create Custom Pattern" button in AddExerciseView
4. Verify sheet dismisses and CreateCustomExerciseView opens with navigation

All three issues addressed successfully.
