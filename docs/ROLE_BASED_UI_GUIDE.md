# AgriEtech Frontend Role-Based Access Control (RBAC) & UI Gating

## 1. Executive Summary

This guide defines how the AgriEtech Flutter client dynamically adapts its interface, action buttons, navigation items, and export permissions according to the **7 formal user roles** in the Ethiopian agricultural hierarchy.

---

## 2. Role Gating Utility (`RoleUtils`)

*File:* [`lib/core/utils/role_utils.dart`](file:///c:/Users/a/Desktop/AgriEtech/agrietech-frontend/lib/core/utils/role_utils.dart)

| Helper Method | Allowed Roles | UI Enforcement Target |
| :--- | :--- | :--- |
| `canCreateAlerts(role)` | `admin`, `regionalOfficer`, `zonalOfficer`, `woredaOfficer`, `developmentAgent` | Floating Action Button on `AlertsListScreen` (`/alerts`). |
| `canManageFarms(role)` | `farmer`, `developmentAgent`, `woredaOfficer`, `zonalOfficer`, `regionalOfficer`, `admin` | `My Farms` module on `HomeScreen` & FAB on `FarmsListScreen`. |
| `canManageSensors(role)` | `developmentAgent`, `woredaOfficer`, `zonalOfficer`, `regionalOfficer`, `admin` | FAB on `SensorsListScreen` (`/sensors/register`). |
| `canCreateDiagnosis(role)` | `farmer`, `developmentAgent`, `woredaOfficer`, `admin` | FAB on `DiagnosisListScreen` (`/diagnosis/create`). |
| `canViewAnalytics(role)` | `researcher`, `regionalOfficer`, `zonalOfficer`, `woredaOfficer`, `admin` | `Agro-Analytics` feature card on `HomeScreen`. |
| `canExportData(role)` | `researcher`, `regionalOfficer`, `zonalOfficer`, `woredaOfficer`, `admin` | `Export Analytics Report` (PDF / CSV) in `AnalyticsScreen`. |
| `canApproveRoleRequests(role)`| `admin`, `regionalOfficer`, `zonalOfficer`, `woredaOfficer` | Administrative role request approval panel. |

---

## 3. Screen Adaptations per Hierarchy Tier

1. **Smallholder Farmer (`FARMER`)**:
   - Clean, simplified interface focused on My Farms GIS, Disease Camera Scanner, Voice AI in Amharic, and Local Alerts.
   - Administrative telemetry, sensor provisioning, and scientific export menus are gracefully hidden.
2. **Development Agent (`DEVELOPMENT_AGENT` / `DA`)**:
   - Field officer interface with IoT sensor registration tools, farm parcel boundary validation, and disease diagnosis triaging.
3. **Woreda & Zonal Officers (`WOREDA_OFFICER`, `ZONAL_OFFICER`)**:
   - Administrative risk map overview, localized emergency broadcast dispatch, and Kebele DA oversight.
4. **Regional Bureau Director (`REGIONAL_OFFICER`)**:
   - Regional aggregated hazard analytics, multi-zone risk tracking, and regional broadcast authority.
5. **Agronomist / Researcher (`RESEARCHER`)**:
   - Full analytical telemetry access, multispectral satellite indices, and scientific PDF/CSV export tools.
6. **National Administrator (`ADMIN`)**:
   - Unrestricted access across all operational modules, user roles, system configs, and IoT devices.
