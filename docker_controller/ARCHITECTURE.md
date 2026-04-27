# Docker Controller Architecture

This document describes the architectural patterns and technical decisions implemented in the Docker Controller Flutter application.

## Overview

The application follows a **Service-Oriented / Feature-First** architecture. It prioritizes clean decoupling between the UI, state management, and business logic, ensuring the codebase remains scalable and maintainable.

---

## Technical Stack

- **Framework**: Flutter
- **State Management**: [Provider](https://pub.dev/packages/provider) with `ChangeNotifier`.
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) for service discovery.
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom interceptors for JWT and error handling.
- **Local Persistence**: `shared_preferences` and `flutter_secure_storage`.
- **UI System**: Custom Glassmorphism design system for a premium aesthetic.

---

## Layers

### 1. Service Layer (`lib/services/`)
The foundation of the app's logic. Services are pure Dart classes responsible for external communication (API, storage, platform channels).
- **Injection**: Services are registered as `LazySingletons` in `lib/core/di/service_locator.dart`.
- **Example**: `ContainerService` handles all interaction with the Docker Engine API regarding containers.

### 2. Provider Layer (`lib/providers/`)
Providers act as the "ViewModels" or controllers for the application. They orchestration one or more services to maintain app state.
- **Decoupling**: Providers do not know about the UI; they simply notify listeners when data changes.
- **Specialization**: Instead of a single "God Provider", the app uses specialized providers:
  - `AuthProvider`: Auth lifecycle and connection configuration.
  - `ContainersProvider`: Container lists, filtering, and basic actions.
  - `SystemStatsProvider`: Real-time telemetry and system metrics.

### 3. UI Layer (`lib/screens/` & `lib/widgets/`)
The visual representation of the app.
- **Observation**: Screens use `Consumer` or `context.watch/read` to interact with providers.
- **Stability**: The UI layer is "dumb"—it delegates all logic to providers.

---

## Dependency Injection (DI) Flow

We use **GetIt** to manage service instances. This allows us to:
1.  **Mock services** easily in unit tests.
2.  **Avoid provider-drilling** for business logic.
3.  **Ensure singletons** for stateful services like the `DioClient`.

**Initialization**:
```dart
// lib/core/di/service_locator.dart
final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerLazySingleton(() => ContainerService());
  getIt.registerLazySingleton(() => DioClient());
  // ...
}
```

---

## Data Flow (Example: Starting a Container)

1.  **User** taps "Start" on `ActionsTab`.
2.  **UI** calls `provider.startContainer(id)`.
3.  **Provider** checks `authProvider.isConnected`.
4.  **Provider** calls `getIt<ContainerService>().startContainer(id)`.
5.  **Service** performs the `POST` request via `DioClient`.
6.  **Service** returns success/failure.
7.  **Provider** updates its local state and calls `notifyListeners()`.
8.  **UI** rebuilds automatically to show the new "Running" status.

---

## Error Handling

Errors are wrapped in the `AppError` model and propagated through the `AppState` class:
- `AppInitial`: No data yet.
- `AppLoading`: Fetching data.
- `AppSuccess<T>`: Data successfully retrieved.
- `AppError`: Something went wrong (includes message and stack trace).
