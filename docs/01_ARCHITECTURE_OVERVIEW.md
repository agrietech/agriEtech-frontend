# AgrieTech Flutter Frontend - Technical Architecture Overview

## Table of Contents
1. [Architecture Philosophy](#architecture-philosophy)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Design Patterns](#design-patterns)
5. [Data Flow](#data-flow)

---

## Architecture Philosophy

### Clean Architecture Principles

**Why Clean Architecture?**
- ✅ **Separation of Concerns**: Each layer has single responsibility
- ✅ **Testability**: Business logic isolated from framework
- ✅ **Maintainability**: Changes in UI don't affect business logic
- ✅ **Scalability**: Easy to add new features without breaking existing ones
- ✅ **Independence**: Framework, database, and UI are replaceable

**Layers:**
```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (Screens, Widgets, Providers)          │
│  - User Interface                       │
│  - State Management (Riverpod)          │
│  - User Input Handling                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         APPLICATION LAYER               │
│  (Providers, Use Cases)                 │
│  - Business Logic                       │
│  - State Orchestration                  │
│  - Validation                           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         DOMAIN LAYER                    │
│  (Models, Entities)                     │
│  - Core Business Models                 │
│  - Domain Rules                         │
│  - Type Definitions                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         DATA LAYER                      │
│  (Repositories, Services)               │
│  - API Communication                    │
│  - Local Storage                        │
│  - External Services                    │
└─────────────────────────────────────────┘
```

### Why This Approach?

**Alternatives Considered:**
1. **MVC (Model-View-Controller)**
   - ❌ Tight coupling between components
   - ❌ Hard to test business logic
   - ❌ Controller becomes bloated
   
2. **MVVM (Model-View-ViewModel)**
   - ⚠️ Better than MVC but still couples UI and logic
   - ⚠️ ViewModels can become complex
   
3. **BLoC (Business Logic Component)**
   - ✅ Good separation
   - ❌ More boilerplate code
   - ❌ Steep learning curve
   - ❌ Streams can be complex

4. **Clean Architecture (Our Choice)**
   - ✅ Maximum testability
   - ✅ Clear separation of concerns
   - ✅ Easy to understand and maintain
   - ✅ Framework independent
   - ⚠️ More initial setup required (worth it for large projects)

---

## Technology Stack

### Core Framework
**Flutter 3.x (Dart 3.x)**

**Why Flutter?**
- ✅ **Single Codebase**: iOS, Android, Web, Desktop from one source
- ✅ **Performance**: Native compilation, 60/120fps smooth animations
- ✅ **Hot Reload**: Instant development feedback
- ✅ **Rich Ecosystem**: 30,000+ packages on pub.dev
- ✅ **Material Design 3**: Built-in modern UI components
- ✅ **Growing Adoption**: Google, Alibaba, BMW use Flutter

**Alternatives Considered:**
1. **React Native**
   - ⚠️ JavaScript bridge impacts performance
   - ⚠️ Requires native modules for many features
   - ❌ Less consistent cross-platform behavior
   
2. **Ionic/Cordova**
   - ❌ WebView-based (poor performance)
   - ❌ Not truly native feel
   
3. **Native (Swift/Kotlin)**
   - ❌ Separate codebases
   - ❌ 2x development time
   - ❌ Inconsistent features

### State Management
**Riverpod 2.x**

**Why Riverpod?**
- ✅ **Compile-time Safety**: Catches errors during development
- ✅ **No BuildContext**: Can use providers anywhere
- ✅ **Better Testing**: Easy to mock providers
- ✅ **Scoped Providers**: Family and autoDispose modifiers
- ✅ **DevTools Integration**: Debug state changes
- ✅ **Performance**: Granular rebuilds, only affected widgets update

**Alternatives:**
1. **Provider (Original)**
   - ❌ Runtime errors
   - ❌ Requires BuildContext
   - ❌ Less type-safe
   
2. **BLoC/Cubit**
   - ⚠️ More boilerplate
   - ⚠️ Streams learning curve
   - ✅ Good for complex state
   
3. **GetX**
   - ❌ Too much magic, hard to debug
   - ❌ Violates Flutter principles
   - ❌ Service locator anti-pattern
   
4. **MobX**
   - ⚠️ Code generation required
   - ⚠️ Less Dart-idiomatic

### Data Serialization
**Freezed + JSON Serializable**

**Why Freezed?**
- ✅ **Immutability**: Thread-safe, predictable state
- ✅ **copyWith**: Easy state updates
- ✅ **Equality**: Automatic == and hashCode
- ✅ **Union Types**: Handle multiple states elegantly
- ✅ **JSON**: Seamless API integration

**Example:**
```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    String? email,
  }) = _UserModel;
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

**Alternatives:**
1. **Manual Serialization**
   - ❌ Error-prone
   - ❌ Boilerplate code
   - ❌ Hard to maintain
   
2. **Built Value**
   - ⚠️ More verbose
   - ⚠️ Steeper learning curve

### Networking
**Dio + Socket.IO Client**

**Why Dio?**
- ✅ **Interceptors**: Global request/response handling
- ✅ **Retry Logic**: Automatic retry on failure
- ✅ **Timeout**: Configurable per request
- ✅ **File Upload**: Multipart support
- ✅ **Cancellation**: Cancel in-flight requests
- ✅ **Mock Support**: Easy testing

**Why Socket.IO?**
- ✅ **Real-time**: Instant updates for alerts, sensors
- ✅ **Reconnection**: Automatic on connection loss
- ✅ **Room Support**: Subscribe to specific channels
- ✅ **Binary Data**: Efficient data transfer
- ✅ **Fallback**: Works behind firewalls

**Alternatives:**
1. **http package**
   - ❌ No interceptors
   - ❌ No retry logic
   - ❌ Basic features only
   
2. **WebSocket (raw)**
   - ❌ Manual reconnection
   - ❌ No room support
   - ❌ More complex to implement

### Local Storage
**Flutter Secure Storage + Hive + Shared Preferences**

**Why Multiple Storage Solutions?**
Each serves different purposes:

**1. Flutter Secure Storage (Tokens)**
- ✅ **Encrypted**: AES encryption, secure keystore
- ✅ **Platform Native**: Keychain (iOS), KeyStore (Android)
- Use: JWT tokens, sensitive credentials

**2. Hive (Offline Data)**
- ✅ **Fast**: Pure Dart, no native dependencies
- ✅ **NoSQL**: Flexible schema
- ✅ **Lazy Loading**: Efficient memory usage
- ✅ **Encryption**: Optional AES-256
- Use: Cached API responses, sync queue

**3. Shared Preferences (Settings)**
- ✅ **Simple**: Key-value store
- ✅ **Platform Native**: UserDefaults, SharedPreferences
- Use: User preferences, theme, language

**Alternatives:**
1. **SQLite**
   - ⚠️ Relational (overkill for our use case)
   - ⚠️ Migration complexity
   - ✅ Good for complex queries
   
2. **Drift (formerly Moor)**
   - ⚠️ Heavy for simple storage
   - ⚠️ Complex setup

### Routing
**GoRouter**

**Why GoRouter?**
- ✅ **Declarative**: Define routes in one place
- ✅ **Type-safe**: Compile-time route validation
- ✅ **Deep Linking**: Handle URLs and notifications
- ✅ **Redirect**: Authentication guards
- ✅ **Nested Routes**: Complex navigation hierarchies
- ✅ **Web Support**: URL-based routing

**Alternatives:**
1. **Navigator 1.0**
   - ❌ Imperative (harder to maintain)
   - ❌ No deep linking
   - ❌ Poor web support
   
2. **Navigator 2.0**
   - ⚠️ Too complex
   - ⚠️ Verbose boilerplate
   - ✅ Full control

3. **Auto Route**
   - ⚠️ Code generation required
   - ⚠️ Additional complexity

---

## Project Structure

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # MaterialApp configuration
├── core/                          # Shared across features
│   ├── config/
│   │   └── env.dart              # Environment variables
│   ├── constants/
│   │   └── app_constants.dart    # Global constants
│   ├── error/
│   │   ├── app_error.dart        # Custom error types
│   │   └── error_handler.dart    # Global error handling
│   ├── models/                    # Shared models
│   │   ├── user_model.dart
│   │   ├── farm_model.dart
│   │   └── weather_model.dart
│   ├── network/
│   │   ├── dio_client.dart       # HTTP client setup
│   │   └── socket_client.dart    # WebSocket client
│   ├── repositories/              # Data access layer
│   │   ├── auth_repository.dart
│   │   └── farm_repository.dart
│   ├── routing/
│   │   └── app_router.dart       # Route definitions
│   ├── services/                  # Business services
│   │   ├── notification_service.dart
│   │   └── sync_service.dart
│   ├── storage/
│   │   └── secure_storage_service.dart
│   ├── theme/
│   │   └── app_theme.dart        # Material Design 3 theme
│   ├── utils/                     # Helper functions
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── role_utils.dart
│   └── widgets/                   # Reusable widgets
│       ├── loading_indicator.dart
│       └── error_view.dart
├── features/                      # Feature modules
│   ├── auth/                     # Authentication
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── dashboard/                # Home dashboard
│   ├── farms/                    # Farm management
│   ├── alerts/                   # Alert system
│   ├── diagnosis/                # Disease diagnosis
│   ├── sensors/                  # IoT sensors
│   ├── risk/                     # Risk assessment
│   ├── boundaries/               # Administrative boundaries
│   ├── analytics/                # Analytics & reports
│   └── home/                     # Home screen
└── generated/                     # Auto-generated files
    └── *.g.dart, *.freezed.dart
```

**Why Feature-based Structure?**
- ✅ **Scalability**: Easy to add new features
- ✅ **Team Collaboration**: Parallel development
- ✅ **Code Ownership**: Clear responsibilities
- ✅ **Maintainability**: Changes localized to feature
- ✅ **Reusability**: Core module shared across features

**Alternative (Layer-based):**
```
lib/
├── models/
├── views/
├── controllers/
└── services/
```
- ❌ Features spread across folders
- ❌ Hard to find related code
- ❌ Tight coupling

---

## Design Patterns

### 1. Repository Pattern

**Purpose**: Abstraction between data sources and business logic

**Implementation:**
```dart
abstract class FarmRepository {
  Future<List<FarmModel>> getFarms();
  Future<FarmModel> createFarm(CreateFarmRequest request);
  Future<FarmModel> updateFarm(String id, UpdateFarmRequest request);
  Future<void> deleteFarm(String id);
}

class FarmRepositoryImpl implements FarmRepository {
  final DioClient _dioClient;
  final HiveInterface _hive;
  
  @override
  Future<List<FarmModel>> getFarms() async {
    // Try cache first (offline-first)
    final cached = _hive.get('farms');
    if (cached != null) return cached;
    
    // Fetch from API
    final response = await _dioClient.get('/farms');
    final farms = (response.data as List)
        .map((e) => FarmModel.fromJson(e))
        .toList();
    
    // Cache for offline
    await _hive.put('farms', farms);
    
    return farms;
  }
}
```

**Benefits:**
- ✅ Single source of truth
- ✅ Easy to swap data sources (API, local, mock)
- ✅ Testable (mock repository)
- ✅ Offline-first strategy

### 2. Provider Pattern (State Management)

**Purpose**: Reactive state management with dependency injection

**Implementation:**
```dart
// Repository Provider
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(
    ref.watch(dioClientProvider),
    ref.watch(hiveProvider),
  );
});

// State Notifier Provider
final farmsProvider = StateNotifierProvider<FarmsNotifier, FarmsState>((ref) {
  return FarmsNotifier(ref.watch(farmRepositoryProvider));
});

// State Class
class FarmsState {
  final List<FarmModel> farms;
  final bool isLoading;
  final AppError? error;
  
  FarmsState({
    this.farms = const [],
    this.isLoading = false,
    this.error,
  });
  
  FarmsState copyWith({
    List<FarmModel>? farms,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
  }) {
    return FarmsState(
      farms: farms ?? this.farms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// State Notifier
class FarmsNotifier extends StateNotifier<FarmsState> {
  final FarmRepository _repository;
  
  FarmsNotifier(this._repository) : super(FarmsState());
  
  Future<void> loadFarms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final farms = await _repository.getFarms();
      state = state.copyWith(farms: farms, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handleError(e),
      );
    }
  }
}
```

**Benefits:**
- ✅ Predictable state changes
- ✅ Easy to test (mock repository)
- ✅ Automatic UI updates
- ✅ Granular rebuilds (only affected widgets)

### 3. Singleton Pattern (Services)

**Purpose**: Single instance of services throughout app

**Implementation:**
```dart
class NotificationService {
  static final NotificationService _instance = 
      NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  Future<void> initialize() async {
    // Setup once
  }
}

// Usage
final notificationService = NotificationService();
```

**Why Singleton for Services?**
- ✅ Single initialization (Firebase, Socket.IO)
- ✅ Shared state (FCM token, connection)
- ✅ Resource efficient (one instance)
- ⚠️ Global state (use sparingly)

### 4. Factory Pattern (Model Creation)

**Purpose**: Flexible object creation

**Implementation:**
```dart
@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    required String title,
    required String message,
    required String severity,
  }) = _AlertModel;
  
  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
  
  // Named constructors (factories)
  factory AlertModel.critical({
    required String title,
    required String message,
  }) {
    return AlertModel(
      id: '',
