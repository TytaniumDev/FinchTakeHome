# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Birdo Tasks is a Flutter gamified task management app where users complete tasks to care for a virtual pet that evolves through growth stages (egg → baby → toddler → child → teenager → adult). Uses Hive for local persistence and Provider/ChangeNotifier for state management.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Generate Hive adapters and JSON serializers (required after entity changes)
flutter pub run build_runner build

# Run the app
flutter run

# Run on Chrome (with DevicePreview disabled by default)
flutter run -d chrome

# Run with CORS disabled for local Flask server testing
flutter run -d chrome --web-browser-flag=--disable-web-security

# Run tests
flutter test

# Run a single test file
flutter test test/models/task_test.dart

# Analyze code
flutter analyze
```

### Backend Server (Optional)

```bash
pip install -r server/requirements.txt
export FLASK_APP=server/app.py; flask run -p 5001
```

Set `enableServer = true` in `lib/core/services/server_service.dart` to connect.

## Architecture

The app uses a **layered architecture** with strict layer responsibilities:

```
Controllers → Managers → Services → Entities
     ↓            ↓          ↓          ↓
Coordination   State     Database   Data Models
              + Logic    (Hive)     + Validation
```

### Layer Decision Tree

1. **Single entity operation?** → Entity
2. **Direct database read/write?** → Service
3. **Domain-specific state management?** → Manager
4. **Cross-domain workflow?** → Controller

### Entities (`lib/model/entities/`)
- Extend `HiveObject` with `@HiveType`/`@HiveField` annotations
- Include factory constructors: `Entity.create({...})`
- Entity-specific validation and simple operations only
- Generated files via `part 'entity.g.dart'`

### Services (`lib/model/services/`)
- **Static methods only** - stateless utility classes
- Support test mode: `enableTestMode(Box<T> testBox)` / `disableTestMode()`
- Pure CRUD operations with Hive
- NO state management, NO business logic, NO cross-service calls

### Managers (`lib/model/managers/`)
- Extend `BaseManager` (which extends `ChangeNotifier`)
- Private fields with public getters: `List<Task> _tasks = []` → `get tasks => _tasks`
- **Always call `notifyListeners()` after state changes**
- Delegate persistence to Services
- Use `ServiceLocator.dateTimeService` for date operations

### Controllers (`lib/controllers/`)
- Extend `BaseController`
- Take managers as constructor dependencies
- Coordinate operations across multiple managers
- Use `log()` method for debug logging

## Key Patterns

### Recurring Tasks
- `RepeatingTask` entities store repeat schedule via `repeatDayIndices` (weekday constants)
- Tasks are injected just-in-time when `TaskService.getTasksForDay()` is called
- Completion tracked per-day in `Day.completedTaskIds`
- Bonus reward (+5 rainbow stones) on recurring task completion

### Day Entity
- `dailyTaskIds: List<String>` stores task IDs (not full Task objects)
- Single source of truth: Tasks live in TaskBox, Days reference by ID
- Migration adapter handles old `List<Task>` format automatically

### Reward System (see `lib/core/constants/rewards.dart`)
- Task completion: `energyReward` field value → pet energy
- Productivity tasks: +10 rainbow stones
- Recurring task bonus: +5 rainbow stones

## Code Style Requirements

### Theming
**Always use `AppTheme` constants** - never hardcode values:
```dart
// Good
padding: EdgeInsets.all(AppTheme.spacing.medium)

// Bad
padding: EdgeInsets.all(16)
```

### Widget Patterns
- Use `Consumer<T>` for reactive updates, `context.read<T>()` for one-time reads
- Prefer `const` constructors
- Use `ListView.builder` for long lists

### Import Order
1. Dart SDK (`dart:async`)
2. Flutter (`package:flutter/material.dart`)
3. Third-party packages (`package:provider/...`)
4. Project imports (`package:birdo/...`)

### Error Handling
- Use try-catch for async operations
- Log with `debugPrint('ClassName: Description: $e')`
- Return null/defaults on error (don't throw unless critical)

## Anti-Patterns to Avoid

```dart
// ❌ Services calling other services
await DayService.getOrCreate(...); // in TaskService

// ❌ Business logic in services (should be in Manager)
task.complete(); // in Service

// ❌ Managers calling other managers (should be in Controller)
await _petManager.addEnergy(...); // in TaskManager

// ❌ Missing notifyListeners after state change
_tasks = await TaskService.getAll(); // forgot notifyListeners()
```

## Known Architectural Debt

1. **Service-to-service dependencies**: `TaskService` calls `DayService.getOrCreate()` - should move to Manager
2. **Business logic in TaskService**: Recurring task injection logic should live in `TaskManager`
3. **Day.energy duplication**: Both Day and Pet track energy separately - can cause inconsistencies

## Testing

- Tests mirror `lib/` structure in `test/`
- Enable test mode: `ServiceName.enableTestMode(testBox)`
- Always disable in `tearDown()`: `ServiceName.disableTestMode()`
- Use `ServiceLocatorTestHelper` for test setup
- Golden tests use `golden_toolkit`
