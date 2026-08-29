# AgriEtech Frontend Feature Modules Catalog

## 1. Catalog of Feature Modules

The AgriEtech client is partitioned into 10 decoupled domain feature modules:

| Module | Route(s) | Primary Purpose |
| :--- | :--- | :--- |
| **`auth`** | `/login`, `/register`, `/forgot-password` | JWT authentication, secure token persistence, and role request registration. |
| **`home`** | `/home` | Navigation shell, high-tech hero telemetry banner, and role-based feature grid. |
| **`risk`** | `/risk-map`, `/disasters`, `/seismology`, `/soil-degradation`, `/landslides`, `/drought-intelligence`, `/flood-intelligence`, `/volcanic-hazards` | Strictly Ethiopian spatial GIS risk map, Master Disaster Hub, and 6 dedicated disaster domain centers. |
| **`farms`** | `/farms`, `/farms/add`, `/farms/:id` | Farm GIS boundary mapping, GPS polygon drawing, and crop acreage tracking. |
| **`alerts`** | `/alerts`, `/alerts/create` | Early warning alert list, real-time filters, and role-gated emergency broadcast creator. |
| **`sensors`** | `/sensors`, `/sensors/register`, `/sensors/:id` | IoT sensor fleet monitoring, battery alerts, soil NPK readings, and QR/manual registration. |
| **`diagnosis`** | `/diagnosis`, `/diagnosis/create` | AI camera leaf scanner, multimodal pathology identification, and chemical/organic prescriptions. |
| **`weather`** | `/weather` | Hyper-local precipitation forecasts, agro-ecological zone temperature tracking, and solar radiation. |
| **`boundaries`** | `/boundaries` | Ethiopian Woreda administrative boundary centroid indexing. |
| **`analytics`** | `/analytics`, `/ussd-console` | Multiscale time-series charts, scientific PDF/CSV report export, and interactive `*212#` USSD phone simulator. |
| **`ai_voice`** | `/ai-assistant` | Multilingual Conversational Voice AI assistant in Amharic & English. |
