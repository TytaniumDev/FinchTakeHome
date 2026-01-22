# Architecture Notes

This document captures architectural decisions, improvements made during development, and areas identified for future refactoring.

## Recent Improvements (Cursor Branch)

The following major architectural improvements were implemented in the cursor branch to address data duplication and improve code maintainability:

### 1. Day Entity Refactoring ✅

**Previous Implementation:**
```dart
@HiveField(5)
List<Task> dailyTasks;  // Stored full Task objects
```

**Current Implementation:**
```dart
@HiveField(5)
List<String> dailyTaskIds;  // Stores only task IDs
```

**Benefits:**
- Eliminates data duplication between `Day` records and the `TaskBox`
- Tasks are now stored in a single source of truth (TaskBox)
- Reduced database size and improved data consistency
- Easier to maintain task updates across days

**Impact:**
- Added migration handler (`day_adapter_migration.dart`) to convert old Day records
- DayManager and TaskService updated to fetch Task objects when needed
- Invalid task IDs are automatically cleaned up

### 2. DayManager Improvements ✅

**Previous Approach:**
DayManager would iterate through stored Task objects in the Day entity.

**Current Approach:**
DayManager fetches tasks from TaskService by ID when needed.

**Example:**
```dart
// Old: Iterate through stored Task objects
for (var task in _currentDay!.dailyTasks) {
  if (task.id == taskId) {
    // Do something with task
  }
}

// New: Fetch task from TaskService
final task = await TaskService.getTask(taskId);
if (task != null) {
  // Do something with task
}
```

**Benefits:**
- Cleaner separation of concerns
- Always works with the latest task data
- No risk of stale task data in Day records

### 3. Recurring Task Tracking ✅

**Implementation:**
Recurring tasks are now properly tracked in the Day's `dailyTaskIds` list for historical record-keeping.

```dart
// When a recurring task appears on a day, its ID is stored
if (!day.dailyTaskIds.contains(recurringTask.id)) {
  day.dailyTaskIds.add(recurringTask.id);
  dayNeedsUpdate = true;
}
```

**Benefits:**
- Can track which recurring tasks appeared on historical days
- Maintains completion status for recurring tasks per day
- Prevents duplicate injection of recurring tasks

## Remaining Architectural Concerns

While significant improvements have been made, the following architectural concerns remain from the original implementation notes ([coding_notes.md](coding_notes.md)):

### 1. Service Layer Separation

**Issue:** TaskService has direct dependencies on DayService, creating tight coupling between persistence layers.

**Current Code:**
```dart
// task_service.dart line 63
static Future<List<Task>> getTasksForDay(DateTime date) async {
  final day = await DayService.getOrCreate(date);  // SERVICE → SERVICE call
  // ... business logic ...
}
```

**Why This Is Problematic:**
- Services should be independent persistence layers
- Creates circular dependencies between services
- Makes unit testing difficult
- Violates single responsibility principle

**Ideal Architecture:**
Services should only handle database operations. Cross-entity logic should live in Managers or Controllers.

**Reference:** [coding_notes.md:80](coding_notes.md#L80)

### 2. Business Logic in Service Layer

**Issue:** The recurring task injection logic lives in TaskService instead of TaskManager.

**Current Location:** `TaskService.getTasksForDay()` (lines 59-145)

**What It Does:**
1. Fetches Day record
2. Fetches stored tasks by ID
3. Finds recurring tasks matching the weekday
4. Injects recurring tasks into the result
5. Updates Day record with new task IDs
6. Handles cleanup of invalid task IDs

**Why This Should Move:**
- This is business logic, not just persistence
- Services should be thin data access layers
- Managers are the appropriate place for this coordination

**Suggested Refactor:**
```dart
// TaskManager (not TaskService)
Future<List<Task>> loadTasksForDay(DateTime date) async {
  // Get day record via DayManager
  final day = await _dayManager.getOrCreateDay(date);

  // Get stored task IDs and fetch tasks
  final tasks = await _fetchTasksById(day.dailyTaskIds);

  // Inject recurring tasks
  final recurringTasks = await _findRecurringTasksForDay(date);
  final allTasks = _mergeTasksWithoutDuplicates(tasks, recurringTasks);

  // Update day if new recurring tasks added
  await _updateDayTaskIds(day, allTasks);

  return allTasks;
}
```

**Reference:** [coding_notes.md:106](coding_notes.md#L106), [approach.md:37](approach.md#L37)

### 3. Day.energy Field Duplication

**Issue:** The Day entity has its own `energy` field that duplicates pet energy data.

**Current Implementation:**
```dart
@HiveField(3)
int energy;  // Tracks energy earned on this day
```

**Duplication:**
- `Pet.currentEnergy` tracks the pet's current energy
- `Day.energy` tracks energy earned on that day
- Can lead to inconsistencies

**Bug Found:** [coding_notes.md:165-166](coding_notes.md#L165)
> Fixed a bug in energy_indicator.dart, it was using the dayManager's total energy field instead of the pet's current energy field for displaying the total energy, so it would often overflow/underflow.

**Potential Improvement:**
Consider computing daily energy from completed tasks rather than storing a separate field:
```dart
// Instead of storing energy
int getTotalEnergy() {
  int total = 0;
  for (final taskId in dailyTaskIds) {
    if (completedTaskIds.contains(taskId)) {
      final task = await TaskService.getTask(taskId);
      total += task?.energyReward ?? 0;
    }
  }
  return total;
}
```

**Trade-off:**
- Pro: Single source of truth
- Con: Requires async operation and task fetches
- Consider: Is this worth the complexity?

**Reference:** [coding_notes.md:166](coding_notes.md#L166), [approach.md:68-69](approach.md#L68)

## Design Decisions & Open Questions

### Undo/Uncomplete Behavior

**Current Implementation:**
When a user uncompletes a task, rewards (energy, rainbow stones) are removed from totals.

**Code:**
```dart
// task_controller.dart
await _petManager.removeEnergy(task.energyReward.toDouble());
await _rainbowStonesManager.removeTaskCompletionStones(amount);
await _dayManager.addRainbowStones(-amount);  // Fixed in this PR
```

**Alternative Approach:**
Instead of removing from past completions, set the next completion to give 0 resources.

**Trade-offs:**

| Approach | Pros | Cons |
|----------|------|------|
| Current (remove rewards) | Simple, intuitive "undo" | Can feel punishing if accidental |
| Next completion gives 0 | Less punishing | More complex, confusing UX |

**Decision Needed:**
This requires product/UX input and user research to determine which approach feels better to users.

**Reference:** [coding_notes.md:161-162](coding_notes.md#L161)

## Future Refactoring Opportunities

### 1. RecurringTask Class

**Idea:** Create a separate class hierarchy for recurring vs one-time tasks.

**Potential Structure:**
```dart
abstract class BaseTask {
  String id;
  String title;
  int energyReward;
  TaskCategory category;
}

class Task extends BaseTask {
  // One-time task specific fields
}

class RecurringTask extends BaseTask {
  List<int> repeatDayIndices;
  // Recurring-specific methods
}
```

**Benefits:**
- Clearer separation of concerns
- Type safety (can't accidentally set repeat days on one-time task)
- Easier to extend with recurring-specific features

**Challenges:**
- Requires Hive adapter changes
- Need to migrate existing data
- More complex than current approach

**Reference:** [approach.md:41-45](approach.md#L41)

### 2. Manager-First Architecture

**Goal:** Move all business logic out of Services and into Managers.

**Current Flow:**
```
UI → Controller → Manager → Service → Database
                     ↓
                  Service → Service (problematic!)
```

**Ideal Flow:**
```
UI → Controller → Manager → Service → Database
                     ↓
                  Manager (coordinates multiple services)
```

**Benefits:**
- Services become pure data access layers
- Easier to test (mock services, test managers)
- Better separation of concerns
- Can swap out persistence layer without touching business logic

**Effort:** High - requires significant refactoring

### 3. Consider Event Sourcing for Day Records

**Idea:** Instead of mutating Day records, store events and compute state.

**Example:**
```dart
// Instead of: day.energy += 5
// Store: DayEvent(type: 'energy_added', amount: 5, timestamp: ...)
```

**Benefits:**
- Complete audit trail
- Can rebuild state at any point
- Undo becomes trivial (remove event)
- Historical analytics

**Challenges:**
- More complex implementation
- Requires event replay logic
- Potentially more storage

**Status:** Interesting idea, but likely overkill for this app's needs.

## Migration Notes

### Day Entity Schema Migration

A custom Hive adapter migration was implemented to handle the schema change from `List<Task>` to `List<String>`:

**File:** [lib/model/entities/day_adapter_migration.dart](lib/model/entities/day_adapter_migration.dart)

**Process:**
1. Detects old Day records with `List<Task>` in field 5
2. Extracts task IDs from the Task objects
3. Creates new Day record with task IDs only
4. Preserves all other fields

**Testing:**
Existing Day records are automatically migrated on first access after the update.

## References

- [coding_notes.md](coding_notes.md) - Detailed implementation notes from take-home exercise
- [approach.md](approach.md) - Overall approach and design decisions
- Original architectural concerns raised during implementation (lines 58-106, 166)

## Summary

**Major Wins:**
- ✅ Eliminated Task object duplication in Day records
- ✅ Improved data consistency with ID-based references
- ✅ Better separation between DayManager and task data

**Still To Address:**
- Service-to-service dependencies (TaskService → DayService)
- Business logic in persistence layer
- Day.energy field duplication with Pet.energy

**Philosophy:**
Incremental improvements over major rewrites. The changes in the cursor branch made significant progress without breaking existing functionality. Future refactoring should follow the same approach: identify specific pain points, make targeted improvements, and maintain backward compatibility where possible.
