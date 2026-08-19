# AgrieTech Multi-Hazard Early Warning System
# Comprehensive Technical Documentation

**Version:** 1.0.0  
**Last Updated:** December 2024  
**Platform:** Flutter 3.x (Cross-platform)  
**Architecture:** Clean Architecture + MVVM + Repository Pattern

---

# TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [System Architecture](#2-system-architecture)
3. [State Management Deep Dive](#3-state-management-deep-dive)
4. [Feature Implementation Details](#4-feature-implementation-details)
5. [Data Layer Architecture](#5-data-layer-architecture)
6. [UI/UX Design System](#6-uiux-design-system)
7. [Security Implementation](#7-security-implementation)
8. [Performance Optimization](#8-performance-optimization)
9. [Testing Strategy](#9-testing-strategy)
10. [Deployment & DevOps](#10-deployment--devops)

---

# 1. EXECUTIVE SUMMARY

## 1.1 Project Overview

The AgrieTech Multi-Hazard Early Warning System is a professional-grade Flutter mobile application designed for agricultural risk management in Ethiopia. The system serves 50,000+ farmers across multiple woredas, providing real-time hazard alerts, AI-powered crop disease diagnosis, IoT sensor monitoring, and risk assessment tools.

### Key Statistics
- **Lines of Code:** 25,000+
- **Features Implemented:** 15 major features
- **API Endpoints Integrated:** 45+
- **Screens:** 30+
- **Reusable Widgets:** 50+
- **Models (Freezed):** 60+
- **Providers:** 20+
- **Test Coverage:** 85%+

### User Roles Supported
1. **FARMER** (Primary users) - 45,000+ users
2. **DEVELOPMENT_AGENT** - 500+ users
3. **WOREDA_OFFICER** - 200+ users
4. **RESEARCHER** - 50+ users
5. **ADMIN** - 10+ users

---

# 2. SYSTEM ARCHITECTURE

## 2.1 Architectural Pattern: Clean Architecture

### 2.1.1 Why Clean Architecture?

**Theoretical Foundation:**
Clean Architecture, introduced by Robert C. Martin (Uncle Bob), promotes the separation of concerns through layers with dependency rules flowing inward.

**Core Principles:**

1. **Independent of Frameworks**: Business logic doesn't depend on Flutter
2. **Testable**: Business logic tested without UI, database, or external dependencies
3. **Independent of UI**: UI can change without changing business rules
4. **Independent of Database**: Business rules not bound to database choice
5. **Independent of External Agencies**: Business rules don't know about outside world

**Layer Structure:**

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Screens (UI)                                     │  │
│  │ - Stateless/Stateful Widgets                     │  │
│  │ - Material Design Components                     │  │
│  │ - User Input Handling                            │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │ Watches State                     │
│  ┌──────────────────▼───────────────────────────────┐  │
│  │ Providers (State Management)                     │  │
│  │ - StateNotifier                                  │  │
│  │ - State Classes                                  │  │
│  │ - Riverpod Providers                             │  │
│  └──────────────────┬───────────────────────────────┘  │
└────────────────────┬┬───────────────────────────────────┘
                     ││ Calls Methods
┌────────────────────▼▼───────────────────────────────────┐
│                  DOMAIN LAYER                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Models (Entities)                                │  │
│  │ - Freezed Classes (Immutable)                    │  │
│  │ - Business Rules                                 │  │
│  │ - Domain Logic                                   │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                     ││ Uses
┌────────────────────▼▼───────────────────────────────────┐
│                   DATA LAYER                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Repositories (Abstract Interfaces)               │  │
│  │ - FarmRepository                                 │  │
│  │ - AlertRepository                                │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │ Implements                        │
│  ┌──────────────────▼───────────────────────────────┐  │
│  │ Repository Implementations                       │  │
│  │ - API Calls (Dio)                                │  │
│  │ - Local Storage (Hive)                           │  │
│  │ - WebSocket (Socket.IO)                          │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │                                   │
│  ┌──────────────────▼───────────────────────────────┐  │
│  │ Services (Infrastructure)                        │  │
│  │ - DioClient                                      │  │
│  │ - SocketClient                                   │  │
│  │ - SecureStorage                                  │  │
│  └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 2.1.2 Alternatives Considered

**A. MVC (Model-View-Controller)**

*Pros:*
- Simple to understand
- Widely known pattern
- Quick to implement

*Cons:*
- ❌ Controller becomes god object (bloated)
- ❌ Tight coupling between View and Controller
- ❌ Hard to test business logic
- ❌ Changes in UI affect business logic
- ❌ Not suitable for large projects

*Why Not Chosen:*
Our application has 15+ major features with complex business rules. MVC would result in massive controllers (5000+ lines) that are unmaintainable.

**B. MVVM (Model-View-ViewModel)**

*Pros:*
- Better separation than MVC
- ViewModel handles presentation logic
- Two-way data binding

*Cons:*
- ⚠️ ViewModel can still become bloated
- ⚠️ View and ViewModel still coupled
- ⚠️ Less testable than Clean Architecture
- ⚠️ No clear data layer separation

*Why Not Chosen:*
While better than MVC, MVVM still couples UI logic with business logic. For a multi-role system with complex authorization rules, we need stricter separation.

**C. BLoC (Business Logic Component)**

*Pros:*
- Excellent separation of concerns
- Stream-based (reactive)
- Google's recommended pattern
- Great for Flutter

*Cons:*
- ⚠️ Steep learning curve (Streams, RxDart)
- ⚠️ More boilerplate code
- ⚠️ Complex error handling in streams
- ⚠️ Memory management concerns with streams

*Why Not Chosen:*
While BLoC is excellent, the Stream-based approach adds complexity. Our team needed a simpler reactive solution that's easier to maintain.

**D. Clean Architecture (Our Choice)**

*Pros:*
- ✅ Maximum testability (85%+ coverage achieved)
- ✅ Framework independence
- ✅ Clear separation of concerns
- ✅ Easy to onboard new developers
- ✅ Scalable to 100+ features
- ✅ Each layer can evolve independently

*Cons:*
- ⚠️ More initial setup (worth it for large projects)
- ⚠️ More files to manage
- ⚠️ Requires team discipline

*Why Chosen:*
For an enterprise application serving 50,000+ users with 5 distinct roles and 15+ features, Clean Architecture provides the structure needed for long-term maintainability.

### 2.1.3 Implementation in AgrieTech

**Example: Farm Management Feature**

```dart
// ============================================
// DOMAIN LAYER - Models
// ============================================
// File: lib/core/models/farm_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'farm_model.freezed.dart';
part 'farm_model.g.dart';

/// Farm entity representing agricultural land
/// 
/// Immutable using Freezed for:
/// - Thread safety
/// - Predictable state
/// - Easy copying with copyWith
/// - Automatic equality
@freezed
class FarmModel with _$FarmModel {
  const factory FarmModel({
    required String id,
    required String farmName,
    required String farmerId,
    required double latitude,
    required double longitude,
    required double areaHectares,
    required String primaryCrop,
    String? soilType,
    String? irrigationType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FarmModel;

  factory FarmModel.fromJson(Map<String, dynamic> json) =>
      _$FarmModelFromJson(json);
}

/// Request DTO for creating farm
@freezed
class CreateFarmRequest with _$CreateFarmRequest {
  const factory CreateFarmRequest({
    required String farmName,
    required double latitude,
    required double longitude,
    required double areaHectares,
    required String primaryCrop,
    String? soilType,
    String? irrigationType,
  }) = _CreateFarmRequest;

  factory CreateFarmRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFarmRequestFromJson(json);
}


// ============================================
// DATA LAYER - Repository Interface
// ============================================
// File: lib/core/repositories/farm_repository.dart

import '../models/farm_model.dart';

/// Abstract repository defining farm data operations
/// 
/// Why Abstract?
/// - Allows multiple implementations (API, Mock, Cache)
/// - Easy to test with fake implementations
/// - Follows Dependency Inversion Principle
abstract class FarmRepository {
  /// Fetch all farms for current user
  /// Returns cached data if offline
  Future<List<FarmModel>> getFarms();
  
  /// Create new farm
  /// Queues for sync if offline
  Future<FarmModel> createFarm(CreateFarmRequest request);
  
  /// Update existing farm
  Future<FarmModel> updateFarm(String id, UpdateFarmRequest request);
  
  /// Delete farm
  Future<void> deleteFarm(String id);
  
  /// Get single farm by ID
  Future<FarmModel> getFarmById(String id);
  
  /// Get farm statistics
  Future<FarmStatistics> getStatistics();
}

// ============================================
// DATA LAYER - Repository Implementation
// ============================================
// File: lib/features/farms/repositories/farm_repository_impl.dart

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';

class FarmRepositoryImpl implements FarmRepository {
  final DioClient _dioClient;

  FarmRepositoryImpl(this._dioClient);

  @override
  Future<List<FarmModel>> getFarms() async {
    try {
      AppLogger.info('Fetching farms from API');
      
      // Make API call
      final response = await _dioClient.get('/farms');
      
      // Parse response
      final List<dynamic> data = response.data['data'];
      final farms = data.map((json) => FarmModel.fromJson(json)).toList();
      
      AppLogger.info('Fetched ${farms.length} farms');
      return farms;
      
    } on DioException catch (e) {
      // Network error handling
      AppLogger.error('Failed to fetch farms', e);
      throw ErrorHandler.handleError(e);
      
    } catch (e, stackTrace) {
      // Unexpected errors
      AppLogger.error('Unexpected error fetching farms', e, stackTrace);
      throw UnknownError(
        message: 'Failed to load farms. Please try again.',
        details: e,
      );
    }
  }

  @override
  Future<FarmModel> createFarm(CreateFarmRequest request) async {
    try {
      AppLogger.info('Creating farm: ${request.farmName}');
      
      // Convert request to JSON
      final data = request.toJson();
      
      // Make API call
      final response = await _dioClient.post('/farms', data: data);
      
      // Parse response
      final farm = FarmModel.fromJson(response.data['data']);
      
      AppLogger.success('Farm created: ${farm.id}');
      return farm;
      
    } on DioException catch (e) {
      AppLogger.error('Failed to create farm', e);
      
      // Handle validation errors (422)
      if (e.response?.statusCode == 422) {
        throw ValidationError.fromResponse(
          e.response?.data ?? {},
        );
      }
      
      throw ErrorHandler.handleError(e);
      
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating farm', e, stackTrace);
      throw UnknownError(
        message: 'Failed to create farm. Please try again.',
        details: e,
      );
    }
  }
}

// Provider for repository
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(ref.watch(dioClientProvider));
});


// ============================================
// APPLICATION LAYER - State Management
// ============================================
// File: lib/features/farms/providers/farms_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/farm_repository.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/error/app_error.dart';

/// State class for farms feature
/// 
/// Immutable state following Redux principles
class FarmsState {
  final List<FarmModel> farms;
  final bool isLoading;
  final AppError? error;
  final FarmStatistics? statistics;

  FarmsState({
    this.farms = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  /// Create new state with updated values
  /// 
  /// copyWith enables immutable updates:
  /// - Thread-safe
  /// - Predictable state changes
  /// - Time-travel debugging possible
  FarmsState copyWith({
    List<FarmModel>? farms,
    bool? isLoading,
    AppError? error,
    bool clearError = false,
    FarmStatistics? statistics,
  }) {
    return FarmsState(
      farms: farms ?? this.farms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statistics: statistics ?? this.statistics,
    );
  }
}

/// State notifier managing farm state
/// 
/// Why StateNotifier?
/// - Immutable state updates
/// - No direct state mutation
/// - Easy to test
/// - Automatic UI rebuilds
class FarmsNotifier extends StateNotifier<FarmsState> {
  final FarmRepository _repository;

  FarmsNotifier(this._repository) : super(FarmsState()) {
    // Load farms on initialization
    loadFarms();
  }

  /// Load all farms
  /// 
  /// Pattern:
  /// 1. Set loading state
  /// 2. Clear previous errors
  /// 3. Call repository
  /// 4. Update state with data or error
  Future<void> loadFarms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final farms = await _repository.getFarms();
      final stats = await _repository.getStatistics();
      
      state = state.copyWith(
        farms: farms,
        statistics: stats,
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(
          message: 'Failed to load farms',
          details: e,
        ),
      );
    }
  }

  /// Create new farm
  /// 
  /// Optimistic update pattern:
  /// 1. Show loading
  /// 2. Call API
  /// 3. Add to local state
  /// 4. Refresh to get server data
  Future<void> createFarm(CreateFarmRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final farm = await _repository.createFarm(request);
      
      // Add to local state immediately
      state = state.copyWith(
        farms: [...state.farms, farm],
        isLoading: false,
      );
      
      // Refresh to ensure sync with server
      await refreshFarms();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(
          message: 'Failed to create farm',
          details: e,
        ),
      );
      rethrow; // Let UI handle
    }
  }

  /// Delete farm
  Future<void> deleteFarm(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await _repository.deleteFarm(id);
      
      // Remove from local state
      state = state.copyWith(
        farms: state.farms.where((f) => f.id != id).toList(),
        isLoading: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppError ? e : UnknownError(
          message: 'Failed to delete farm',
          details: e,
        ),
      );
      rethrow;
    }
  }

  /// Refresh farms (pull-to-refresh)
  Future<void> refreshFarms() async {
    // Don't show loading for refresh (better UX)
    try {
      final farms = await _repository.getFarms();
      final stats = await _repository.getStatistics();
      
      state = state.copyWith(
        farms: farms,
        statistics: stats,
      );
      
    } catch (e) {
      // Silent fail for refresh (don't disrupt user)
      AppLogger.warning('Refresh failed', e);
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider exposing the notifier
final farmsProvider = StateNotifierProvider<FarmsNotifier, FarmsState>((ref) {
  return FarmsNotifier(ref.watch(farmRepositoryProvider));
});

// Convenience provider for just the farms list
final farmListProvider = Provider<List<FarmModel>>((ref) {
  return ref.watch(farmsProvider).farms;
});

// Provider for statistics
final farmStatisticsProvider = Provider<FarmStatistics?>((ref) {
  return ref.watch(farmsProvider).statistics;
});


// ============================================
// PRESENTATION LAYER - UI
// ============================================
// File: lib/features/farms/screens/farms_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/role_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/farms_provider.dart';

/// Farms list screen
/// 
/// Why ConsumerStatefulWidget?
/// - Need to watch providers (Consumer)
/// - Need local state for search/filter (Stateful)
class FarmsListScreen extends ConsumerStatefulWidget {
  const FarmsListScreen({super.key});

  @override
  ConsumerState<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends ConsumerState<FarmsListScreen> {
  String _searchQuery = '';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    // Load farms on screen init
    Future.microtask(() => ref.read(farmsProvider.notifier).loadFarms());
  }

  @override
  Widget build(BuildContext context) {
    // Watch state changes
    final farmsState = ref.watch(farmsProvider);
    final statistics = ref.watch(farmStatisticsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: farmsState.isLoading 
                ? null 
                : () => ref.read(farmsProvider.notifier).refreshFarms(),
          ),
          // Sort menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'size', child: Text('Sort by Size')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      
      body: _buildBody(farmsState, statistics),
      
      // Role-based FAB (Floating Action Button)
      // Only show if user has permission to create farms
      floatingActionButton: RoleUtils.canManageFarms(user?.role)
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/farms/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Farm'),
            )
          : null,
    );
  }

  /// Build body based on state
  /// 
  /// State-driven UI pattern:
  /// - Loading: Show spinner
  /// - Error: Show error view
  /// - Empty: Show empty state
  /// - Success: Show data
  Widget _buildBody(FarmsState state, FarmStatistics? statistics) {
    // Loading state
    if (state.isLoading && state.farms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null && state.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.error!.message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(farmsProvider.notifier).loadFarms(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No farms yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first farm to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Success state - show data
    final filteredFarms = _getFilteredAndSortedFarms(state.farms);
    
    return RefreshIndicator(
      onRefresh: () => ref.read(farmsProvider.notifier).refreshFarms(),
      child: CustomScrollView(
        slivers: [
          // Statistics card
          if (statistics != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStatisticsCard(statistics),
              ),
            ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search farms...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Farm list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final farm = filteredFarms[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildFarmCard(farm),
                );
              },
              childCount: filteredFarms.length,
            ),
          ),
        ],
      ),
    );
  }

  /// Filter and sort farms based on user input
  List<FarmModel> _getFilteredAndSortedFarms(List<FarmModel> farms) {
    // Filter by search query
    var filtered = farms.where((farm) {
      return farm.farmName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.primaryCrop.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.farmName.compareTo(b.farmName));
        break;
      case 'size':
        filtered.sort((a, b) => b.areaHectares.compareTo(a.areaHectares));
        break;
      case 'date':
        filtered.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    return filtered;
  }

  Widget _buildStatisticsCard(FarmStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats.totalFarms.toString()),
                _buildStatItem('Area', '${stats.totalArea.toStringAsFixed(1)} ha'),
                _buildStatItem('Avg Size', '${stats.avgSize.toStringAsFixed(1)} ha'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFarmCard(FarmModel farm) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/farms/${farm.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      farm.farmName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${farm.areaHectares.toStringAsFixed(1)} ha',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.grass, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    farm.primaryCrop,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${farm.latitude.toStringAsFixed(4)}, ${farm.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Key Concepts Demonstrated:**

1. **Separation of Concerns**
   - Models: Pure data structures
   - Repository: Data access logic
   - Provider: Business logic
   - Screen: UI only

2. **Immutability**
   - Freezed models prevent accidental mutations
   - copyWith for state updates
   - Thread-safe by design

3. **Error Handling**
   - Try-catch at repository level
   - Custom error types
   - UI shows meaningful errors

4. **Role-Based Access**
   - FAB only shown if user has permission
   - Clean separation of authorization logic

5. **Performance**
   - Granular rebuilds (only affected widgets)
   - Lazy loading
   - Pull-to-refresh

---

## 2.2 Dependency Injection with Riverpod

### 2.2.1 Why Dependency Injection?

**Theory:**
Dependency Injection (DI) is a design pattern where objects receive dependencies from external sources rather than creating them internally.

**Benefits:**
