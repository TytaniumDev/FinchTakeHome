# Birdo Tasks Architecture Rules

Follow these architectural patterns when working on the Birdo Tasks codebase.

## Layer Responsibilities

### Entities (`lib/model/entities/`)
- Define data structures and domain objects
- Contain entity-specific validation and simple operations
- Examples: `Task`, `Pet`, `Day`
- **Place entity-specific logic here**: Methods that operate on a single entity's data
  - Example: `pet.isReadyToEvolve()`, `task.completeTask()`

### Services (`lib/model/services/`)
- Pure data access layer - stateless utility classes
- Use static methods for database operations (CRUD with Hive)
- NO state management or notifications
- Handle direct persistence only
- **Place data persistence operations here**: Direct database reads/writes
  - Example: `PetService.createNewPet()`, `DayService.getOrCreate()`

### Managers (`lib/model/managers/`)
- State management + domain logic layer
- Maintain in-memory state (e.g., current tasks, current day)
- Extend `ChangeNotifier` to provide reactive updates
- Delegate data persistence to Services
- **Place domain-specific state management here**: Logic for managing and notifying about domain-specific state
  - Example: `TaskManager.loadTasksForDay()`, maintaining list of tasks and notifying listeners

### Controllers (`lib/controllers/`)
- Coordination + workflow layer
- Orchestrate operations across multiple managers
- Handle complex workflows and user interactions
- Implement cross-domain business logic
- **Place cross-domain workflows here**: Logic that coordinates multiple managers/domains
  - Example: `HomeController.completeTask()` coordinating updates across task, pet, and day managers

## Decision Tree: Where Does This Logic Go?

1. **Does it operate on a single entity's data?** → Entity
2. **Does it directly read/write to the database?** → Service
3. **Does it manage state for a specific domain?** → Manager
4. **Does it coordinate across multiple domains?** → Controller

## Code Patterns

### Services Pattern
```dart
class ExampleService {
  static Future<Entity> create(params) async {
    // Direct Hive database operation
  }

  static Future<Entity?> get(id) async {
    // Direct Hive database read
  }
}
```

### Managers Pattern
```dart
class ExampleManager extends ChangeNotifier {
  List<Entity> _entities = [];

  Future<void> loadEntities() async {
    _entities = await ExampleService.getAll();
    notifyListeners(); // Notify UI of state change
  }
}
```

### Controllers Pattern
```dart
class ExampleController {
  final ManagerA _managerA;
  final ManagerB _managerB;

  Future<void> complexWorkflow() async {
    // Coordinate between multiple managers
    await _managerA.doSomething();
    await _managerB.doSomethingElse();
  }
}
```

## Key Principles

1. **Separation of Concerns**: Each layer has a distinct responsibility
2. **Unidirectional Dependencies**: Controllers → Managers → Services → Entities
3. **Stateless Services**: Services should never maintain state
4. **Reactive Managers**: Managers notify listeners when state changes
5. **Coordination in Controllers**: Complex workflows span controllers, not managers

## When Making Changes

- **Adding a new feature**: Identify which domains it affects, then add logic at the appropriate layer
- **Modifying existing code**: Respect the existing layer structure - don't add controller logic to services
- **Refactoring**: Move logic to the correct layer if it's misplaced
- **New entities**: Create in `entities/`, add service for persistence, add manager for state if needed
