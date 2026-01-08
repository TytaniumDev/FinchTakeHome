# Birdo Tasks
A gamified task management app that helps you stay productive while taking care of your virtual pet. 

## Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.38.3)
- [Dart SDK](https://dart.dev/get-dart) (3.10.1)
- [Python](https://www.python.org/downloads/) (^3.9.0)

Note that you can run flutter on web or iOS simulators. If you'd like to use iOS simulators, please make sure to download Xcode, and iOS SDK and setup simulators prior to the interview. See [additional components](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) and [simulators](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device) for more information.

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the code generation for Hive:
```bash
flutter pub run build_runner build
```

3. Run the app:
```bash
flutter run
```

### Running the server
Install server dependencies by running 
```bash 
pip install -r server/requirements.txt
```
(Note: if you don't have pip downloaded yet run `python -m ensurepip --upgrade`)

We use a local sqlite database for our server data storage. You'll need to create it before you can use the server. Run the following command
to get started, and re-run it whenever you change server side schema:
```python
from server.database import init; init.reset_database()
```

Finally run flask via this command:
Then run the server via 
```bash 
export FLASK_APP=server/app.py; flask run -p 5001
```

Note: Flask defaults to port 5000. We use port 5001 since macOS will often use port 5000 for AirPlay.

### CORS Workaround
You can ignore this if running the client via an iOS simulator.

If using a webrowser to debug, the browser will block requests to the localhost flask server. You can bypass this behavior by using the following
command to run flutter:
```bash
flutter run -d chrome --web-browser-flag=--disable-web-security
```


### Server <--> Client communication
By default the client will ignore all requests made to the server.
To configure the client to run against your local flask server set `enableServer = true` in `lib/core/services/server_service.dart`.

## Development

The app uses several key packages:
- `device_preview`: For testing the app on different device sizes
- `hive_ce`: For local data persistence
- `provider`: For state management
- `flutter_lints`: For maintaining code quality
- `equatable`: For value equality comparisons

### Browser Preview
To preview the app in a browser, you can enable the DevicePreview flag in `lib/main.dart`. Change the `enabled` parameter to `true` in the following code:

```dart
runApp(
  DevicePreview(enabled: true, builder: (context) => const BirdoTasks()),
);
```

You can find this code at [lib/main.dart#L46-L48](https://github.com/Finch-Care/finch-eng-onsite/blob/main/lib/main.dart#L87-L89).

Running `flutter run -d chrome` will open the app preview in the browser.

## Project Structure

- `lib/`: Contains the main application code
  - `core/`: Core functionality and services
    - `constants/`: App-wide constants
    - `services/`: Service layer implementations
    - `theme/`: UI theming and styling
  - `model/`: Data and business logic layer
    - `entities/`: Data models and domain objects
    - `services/`: Data access and persistence services
    - `managers/`: State management and business logic
  - `controllers/`: Application workflow coordination
  - `view/`: UI layer
    - `screens/`: UI screens
    - `widgets/`: Reusable widgets
  - `assets/`: Static assets and resources
- `test/`: Contains test files
- `ios/`: iOS-specific code
- `android/`: Android-specific code
- `web/`: Web-specific code
- `server/`: Codebase for python flask server. 

## Architecture
### Services
- Pure Data Access Layer
- Stateless utility classes with static methods
- Handle direct database operations (CRUD with Hive)
- No state management or notifications
- Example: `PetService.createNewPet()` directly creates a pet in the database
### Managers
- State Management + Domain Logic Layer
- Maintain in-memory state (e.g., current tasks, current day)
- Extend ChangeNotifier to provide reactive updates
- Implement domain-specific business logic
- Delegate data persistence to Services
- Example: `TaskManager` maintains a list of tasks and notifies listeners when it changes
### Controllers
- Coordination + Workflow Layer
- Orchestrate operations across multiple managers
- Handle complex workflows and user interactions
- Implement cross-domain business logic
- Example: `HomeController.completeTask()` coordinates updates across task, pet, and day managers
### Entities
- Data Structure Layer
- Define the structure of domain objects
- May contain entity-specific validation and simple operations
- Example: `Task` defines the structure of a task and basic operations like `completeTask()`

## Business Logic Distribution Guidelines
The distribution of business logic follows these principles:

**Entity-specific logic** → Place in the entity itself

Example: `pet.isReadyToEvolve()` belongs in the Pet class

**Domain-specific state management** → Place in managers

Example: `TaskManager.loadTasksForDay()` manages task state for a specific day

**Cross-domain workflows** → Place in controllers

Example: When completing a task affects the pet's energy and day's record, this coordination logic belongs in the controller

**Data persistence operations** → Place in services

Example: `DayService.getOrCreate()` handles the database interaction
