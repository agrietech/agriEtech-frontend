import '../config/env.dart';

/// API Configuration Constants matching full API_SPECIFICATION.md
class ApiConstants {
  // Base URLs
  static String get baseUrl => AppEnv.apiBaseUrl.replaceAll('/api/v1', '');
  static const String apiVersion = '/api/v1';
  static String get baseApiUrl => AppEnv.apiBaseUrl;

  // Socket.IO
  static String get socketUrl => AppEnv.socketBaseUrl;

  // 1. Authentication Endpoints (/auth)
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh-token';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/me';
  static const String updatePassword = '$auth/update-password';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';
  static const String resendVerification = '$auth/resend-verification';
  static const String roleRequests = '$auth/role-requests';

  // 2. Administrative Boundary Endpoints (/boundaries)
  static const String boundaries = '/boundaries';
  static const String regions = '$boundaries/regions';
  static const String zones = '$boundaries/zones';
  static const String woredas = '$boundaries/woredas';
  static String woredaById(String id) => '$boundaries/woredas/$id';

  // 3. Farm Plot Registry Endpoints (/farms)
  static const String farms = '/farms';
  static String farmById(String id) => '$farms/$id';

  // 4. IoT Sensor Telemetry Endpoints (/sensors)
  static const String sensors = '/sensors';
  static const String telemetry = '$sensors/telemetry';
  static String farmSensors(String farmId) => '$sensors/farm/$farmId';
  static String sensorLatest(String hardwareId) => '$sensors/$hardwareId/latest';
  static String sensorTelemetryHistory(String hardwareId) => '$sensors/$hardwareId/telemetry';

  // 5. Satellite & Climate Observations (/satellite-observations)
  static const String satelliteObservations = '/satellite-observations';
  static String satelliteWoreda(String woredaId) => '$satelliteObservations/woreda/$woredaId';
  static const String satelliteIngest = '$satelliteObservations/ingest';

  // 6. Multi-Hazard Risk Assessment Endpoints (/risk-assessments)
  static const String riskAssessments = '/risk-assessments';
  static const String evaluateRisk = '$riskAssessments/evaluate';
  static String riskByWoreda(String woredaId) => '$riskAssessments/woreda/$woredaId';
  static const String riskStatistics = '$riskAssessments/statistics';
  static String riskStats([String? period]) => '$riskAssessments/statistics';

  // 7. Early Warning Alert Endpoints (/alerts)
  static const String alerts = '/alerts';
  static String alertById(String id) => '$alerts/$id';
  static String alertMarkRead(String id) => '$alerts/$id/read';

  // 8. AI Crop Disease Diagnosis Endpoints (/disease-diagnosis)
  static const String diseaseDiagnosis = '/disease-diagnosis';
  static const String diagnose = '$diseaseDiagnosis/diagnose';
  static String farmDiagnoses(String farmId) => '$diseaseDiagnosis/farm/$farmId';

  // 9. Analytics & Agronomic Advisories (/analytics)
  static const String analytics = '/analytics';
  static const String dashboard = '$analytics/dashboard';
  static const String regionalBreakdown = '$analytics/regional-breakdown';
  static const String temporalTrends = '$analytics/temporal-trends';
  static const String agronomicAdvisories = '$analytics/agronomic-advisories';
  static const String analyticsAiInsights = '$analytics/ai-insights';

  // 9A. Location-Based Map & Analytics (/analytics/location)
  static const String locationMap = '$analytics/location/map';
  static const String locationAnalytics = '$analytics/location/analytics';
  static String regionMap(String regionId) => '$analytics/region/$regionId/map';
  static String regionAnalytics(String regionId) => '$analytics/region/$regionId/analytics';
  static String zoneMap(String zoneId) => '$analytics/zone/$zoneId/map';
  static String zoneAnalytics(String zoneId) => '$analytics/zone/$zoneId/analytics';
  static String woredaMap(String woredaId) => '$analytics/woreda/$woredaId/map';
  static String woredaAnalytics(String woredaId) => '$analytics/woreda/$woredaId/analytics';

  // 10. AI Voice & Multimodal Assistant (/ai)
  static const String aiVoiceInquiry = '/ai/voice-inquiry';
  static const String aiTextInquiry = '/ai/text-inquiry';
  static const String aiSpeakResponse = '/ai/speak';
  static const String aiTextToSpeech = '/ai/text-to-speech';

  // 11. Data Ingestion Pipeline (/ingestion)
  static const String ingestion = '/ingestion';
  static const String connectors = '$ingestion/connectors';
  static const String ingestionHealth = '$ingestion/health';
  static const String triggerIngestion = '$ingestion/trigger';
  static const String ingestionPull = '$ingestion/pull';
  static const String ingestionTelemetry = '$ingestion/telemetry';
  static const String queueStats = '$ingestion/queue/stats';
  static String retryJob(String jobId) => '$ingestion/jobs/$jobId/retry';

  // 12. USSD Gateway (/delivery/ussd)
  static const String ussdGateway = '/delivery/ussd';

  // 13. Admin & Audit Control (/admin)
  static const String adminOverview = '/admin/overview';
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  static String adminUserRole(String id) => '/admin/users/$id/role';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static const String adminFarms = '/admin/farms';
  static String adminFarmById(String id) => '/admin/farms/$id';
  static const String adminSensors = '/admin/sensors';
  static String adminSensorById(String id) => '/admin/sensors/$id';
  static const String adminAlerts = '/admin/alerts';
  static String adminAlertById(String id) => '/admin/alerts/$id';
  static const String adminBroadcastAlert = '/admin/broadcast-alert';
  static const String adminDiagnoses = '/admin/diagnoses';
  static String adminDiagnosisById(String id) => '/admin/diagnoses/$id';
  static const String adminSystemHealth = '/admin/system/health';
  static const String adminIngestionTrigger = '/admin/ingestion/trigger';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminRoleRequests = '/admin/role-requests';
  static String adminApproveRoleRequest(String id) => '/admin/role-requests/$id/approve';
  static String adminRejectRoleRequest(String id) => '/admin/role-requests/$id/reject';

  // Request Timeouts
  static Duration get defaultTimeout => AppEnv.apiTimeout;
  static Duration get longTimeout => AppEnv.longApiTimeout;

  // File Upload Constraints
  static int get maxFileSizeBytes => AppEnv.maxImageSizeMB * 1024 * 1024;
  static List<String> get allowedImageFormats => AppEnv.allowedImageFormats;
}
