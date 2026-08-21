# Admin Dashboard - Backend Implementation

## Overview
The admin dashboard has been removed from the Flutter frontend application and will be implemented as a backend web interface accessible via Render or similar hosting platform.

---

## Changes Made

### ✅ Removed from Flutter Frontend

1. **Admin Feature Directory** - Deleted
   - `/lib/features/admin/` - Complete directory removed
   - All admin screens, providers, and repositories removed

2. **No Admin Routes in App**
   - Router configuration has NO admin routes
   - No navigation to admin dashboard from mobile app

3. **Clean Separation**
   - Mobile app: User-facing features only
   - Backend admin: Separate web interface

---

## Admin API Endpoints (Still Available)

The backend API endpoints remain available for the backend admin interface:

### User Management
```
GET    /admin/users              - List all users
POST   /admin/users              - Create new user
GET    /admin/users/:id          - Get user details
PUT    /admin/users/:id          - Update user
DELETE /admin/users/:id          - Delete user
PATCH  /admin/users/:id/role     - Update user role
PATCH  /admin/users/:id/status   - Update user status
```

### Platform Management
```
GET    /admin/overview           - System metrics
GET    /admin/system/health      - System health check
GET    /admin/audit-logs         - Audit logs
POST   /admin/broadcast-alert    - Emergency broadcast
POST   /admin/ingestion/trigger  - Trigger data ingestion
```

### Resource Management
```
GET    /admin/farms              - All farms
GET    /admin/sensors            - All sensors
GET    /admin/alerts             - All alerts
GET    /admin/diagnoses          - All diagnoses
```

---

## Backend Admin Interface Requirements

### Recommended Tech Stack

**Option 1: Node.js Admin Panel**
- **Admin Bro / AdminJS** - Auto-generates admin panel
- **Express Admin** - Simple admin interface
- **React Admin** - Full-featured admin dashboard

**Option 2: Python Admin Panel**
- **Django Admin** - Built-in admin interface
- **Flask-Admin** - Flask admin extension
- **FastAPI Admin** - Modern async admin

**Option 3: Standalone Admin**
- **Retool** - Low-code admin builder
- **Budibase** - Open-source low-code platform
- **Appsmith** - Internal tool builder

---

## Required Admin Features

### 1. User Management ✅
- View all registered users
- Display: Name, Phone, Email, Role
- **Location Data**: Region, Zone, Woreda
- CRUD operations:
  - Create new users
  - Edit user details
  - Update user roles
  - Delete users
- Search and filter capabilities
- Pagination for large datasets

### 2. System Monitoring ✅
- System health dashboard
- Platform metrics:
  - Total users
  - Active farms
  - IoT sensors online
  - Active alerts
- Real-time status indicators

### 3. Emergency Broadcast ✅
- Send emergency alerts
- Target specific woredas or all users
- Multi-channel: SMS + Push notifications
- Hazard types: Drought, Flood, Locust, Disease
- Severity levels: Low, Moderate, High, Critical
- Bilingual support: English + Amharic

### 4. Data Ingestion ✅
- View active connectors
- Manual ingestion triggers
- Supported sources:
  - CHIRPS (Rainfall)
  - Open-Meteo (Weather)
  - NASA POWER (Agro data)
  - MODIS (Vegetation indices)

### 5. Audit Logging ✅
- Track all admin actions
- User activity logs
- System events
- Timestamped records

---

## Deployment on Render

### Backend Admin Setup

**Step 1: Create Admin Web Service**
```yaml
# render.yaml
services:
  - type: web
    name: agrietech-admin
    env: node
    buildCommand: npm install && npm run build:admin
    startCommand: npm run start:admin
    envVars:
      - key: NODE_ENV
        value: production
      - key: ADMIN_PORT
        value: 3001
      - key: DATABASE_URL
        fromDatabase:
          name: agrietech-db
          property: connectionString
```

**Step 2: Secure Admin Access**
```javascript
// Basic authentication middleware
const adminAuth = (req, res, next) => {
  const auth = req.headers.authorization;
  if (!auth || !verifyAdminToken(auth)) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
};

app.use('/admin', adminAuth, adminRoutes);
```

**Step 3: Environment Variables**
```
ADMIN_USERNAME=admin
ADMIN_PASSWORD=<secure-password>
JWT_SECRET=<your-jwt-secret>
DATABASE_URL=<postgres-connection-string>
```

---

## User Data Display Format

### Location Hierarchy
All users must display complete location information:

```javascript
// Example user object structure
{
  id: "user123",
  fullName: "Abebe Bikila",
  phone: "+251912345678",
  email: "abebe@example.com",
  role: "FARMER",
  
  // Location data
  woredaId: "woreda_xyz",
  woredaName: "Bishoftu",
  zoneName: "East Shewa",
  regionName: "Oromia",
  
  // Or nested format
  woreda: {
    id: "woreda_xyz",
    name: "Bishoftu",
    zone: {
      name: "East Shewa",
      region: {
        name: "Oromia"
      }
    }
  }
}
```

**Display Format:**
```
📍 Oromia > East Shewa > Woreda: Bishoftu
```

---

## Security Considerations

### 1. Authentication
- Admin-only access with strong credentials
- JWT token-based authentication
- Session timeout after inactivity

### 2. Authorization
- Role-based access control (RBAC)
- Admin users only
- Audit all admin actions

### 3. Data Protection
- HTTPS only
- Secure password hashing
- Rate limiting on sensitive endpoints
- IP whitelisting (optional)

### 4. Audit Trail
- Log all CRUD operations
- Track user changes
- Record broadcast alerts sent
- Maintain data ingestion history

---

## API Documentation

Full API documentation available at:
- **File**: `docs/API_DOCUMENTATION.md`
- **Endpoints**: All `/admin/*` routes documented
- **Authentication**: Bearer token required
- **Response formats**: JSON with consistent structure

---

## Sample Admin Interface Screens

### 1. User Management Screen
```
╔══════════════════════════════════════════════════════════╗
║  👥 User Management                    [+ Add User]      ║
╠══════════════════════════════════════════════════════════╣
║  Search: [________________] 🔍  Filter: [All Roles ▼]   ║
╠══════════════════════════════════════════════════════════╣
║                                                           ║
║  AB  Abebe Bikila              FARMER                    ║
║      +251912345678 • abebe@example.com                   ║
║      📍 Oromia > East Shewa > Woreda: Bishoftu          ║
║                                     [Edit] [Delete]       ║
║  ─────────────────────────────────────────────────────── ║
║  TG  Tigist Getachew           WOREDA_OFFICER            ║
║      +251923456789 • tigist@example.com                  ║
║      📍 Amhara > North Shewa > Woreda: Debre Birhan     ║
║                                     [Edit] [Delete]       ║
╚══════════════════════════════════════════════════════════╝
```

### 2. Emergency Broadcast Screen
```
╔══════════════════════════════════════════════════════════╗
║  🚨 Emergency Alert Broadcast                            ║
╠══════════════════════════════════════════════════════════╣
║                                                           ║
║  Target Woreda: [All Woredas ▼]                         ║
║  Hazard Type:   [Drought ▼]    Severity: [High ▼]      ║
║                                                           ║
║  Title (EN):    [_______________________________]        ║
║  Title (AM):    [_______________________________]        ║
║  Message (EN):  [________________________________        ║
║                  ________________________________]        ║
║  Message (AM):  [________________________________        ║
║                  ________________________________]        ║
║                                                           ║
║  ☑ Push Notification    ☑ SMS                           ║
║                                                           ║
║             [Send Emergency Broadcast]                    ║
╚══════════════════════════════════════════════════════════╝
```

---

## Migration Checklist

- [x] Remove admin feature from Flutter app
- [x] Keep API endpoints active
- [x] Document admin requirements
- [ ] Implement backend admin interface
- [ ] Deploy admin panel to Render
- [ ] Set up admin authentication
- [ ] Configure environment variables
- [ ] Test all CRUD operations
- [ ] Verify location data display
- [ ] Test emergency broadcast
- [ ] Set up audit logging
- [ ] Configure backups

---

## Support & Maintenance

**Admin Panel Access:**
- URL: `https://agrietech-admin.onrender.com` (example)
- Authentication: Admin credentials required
- Support: Backend development team

**Mobile App:**
- No admin access from mobile
- Users access only their own features
- Admin managed separately

---

## Summary

✅ **Admin dashboard removed from Flutter app**  
✅ **API endpoints remain available for backend admin**  
✅ **All admin features documented for backend implementation**  
✅ **Security and deployment guidelines provided**  
✅ **Clean separation between user app and admin panel**  

The mobile application is now focused solely on end-user features, while admin functionality will be accessed through a secure web interface hosted on Render or similar platform.
