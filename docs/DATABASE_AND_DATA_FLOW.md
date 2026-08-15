# Frontend Data Flow, Offline Caching & Architecture Diagrams

This document details the reactive state management and offline-first synchronization architecture of the AgriEtech Flutter mobile client.

---

## 1. Complete Mobile Client State & Caching Architecture Diagram

```mermaid
flowchart TD
    subgraph UI_Layer["Presentation / UI Layer"]
        Screen["Screen Widget (e.g. RiskDashboardScreen)"]
        CustomWidget["Custom Component (e.g. DroughtGauge, MultiHazardMap)"]
        UserAction["User Action / Lifecycle Event"]
    end

    subgraph State_Layer["Riverpod 2.x State Management"]
        Notifier["AsyncNotifier / StateNotifier Provider"]
        StateData["AsyncValue State: (Loading | Data | Error)"]
    end

    subgraph Repository_Layer["Feature Repository Layer"]
        Repo["FeatureRepository (Clean Architecture)"]
    end

    subgraph Cache_Layer["Local Storage Layer (Offline-First)"]
        HiveBox[("Hive NoSQL Boxes (Weather, Risk, Farms)")]
        SecureStore[("FlutterSecureStorage (Encrypted JWT)")]
    end

    subgraph Network_Layer["Remote Transport Layer"]
        DioClient["Dio HTTP Client (REST API)"]
        Interceptors["Auth & Error Interceptors"]
        SocketClient["Socket.IO Client (Real-Time Streams)"]
    end

    subgraph Background_Layer["Background Synchronization"]
        Workmanager["Workmanager Background Task"]
        ConnPlus["ConnectivityPlus Network Listener"]
    end

    UserAction --> Screen
    Screen --> Notifier
    CustomWidget --> Notifier
    Notifier --> StateData
    StateData -->|"Rebuilds Reactive UI"| Screen

    Notifier --> Repo
    Repo -->|"1. Immediate Cache Read"| HiveBox
    HiveBox -->|"Return Cached Data Instantly"| Notifier

    Repo -->|"2. Fetch Fresh Data"| DioClient
    DioClient <--> Interceptors
    Interceptors <-->|"Attach Bearer Token"| SecureStore
    DioClient -->|"3. Write Fresh Data to Cache"| HiveBox
    HiveBox -->|"Emit Fresh State"| Notifier

    SocketClient -->|"Live 'risk:updated' Event"| Notifier

    ConnPlus -->|"Network Restored?"| Workmanager
    Workmanager -->|"Flush Pending Offline Data"| DioClient
```

---

## 2. Low-Connectivity Offline-First Strategy
1. **Zero Blank Screens**: When navigating between screens (Weather, Risk, Farms, Soil), the app loads from Hive NoSQL cache in **< 16 milliseconds**.
2. **Graceful Network Handling**: If the phone is in an area without signal (e.g. deep rural fields), the app displays cached data alongside a subtle banner indicating the timestamp of the last satellite synchronization.
3. **Offline Field Action Logging**: Development agents can register new farm boundary polygons or take crop disease photos completely offline. The records are saved in Hive and automatically uploaded by `BackgroundSyncWorker` when network connectivity returns.
