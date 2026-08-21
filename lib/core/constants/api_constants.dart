import '../config/env.dart';

/// API Configuration Constants
class ApiConstants {
  // Base URLs
  static String get baseUrl => AppEnv.apiBaseUrl.replaceAll('/api/v1', '');
  static const String apiVersion = '/api/v1';
  static String get baseApiUrl => AppEnv.apiBaseUrl;

  // Socket.IO
  static String get socketUrl => AppEnv.socketBaseUrl;

  // Authentication Endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh-token';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/me';
  static const String updatePassword = '$auth/update-password';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';

  // Farm Management Endpoints
  static const String farms = '/farms';
  static String farmById(String id) => '$farms/$id';

  // Risk Assessment Endpoints
  static const String riskAssessments = '/risk-assessments';
  static const String evaluateRisk = '$riskAssessments/evaluate';
  static String riskByWoreda(String woredaId) => '$riskAssessments/woreda/$woredaId';
  static const String riskStatistics = '$riskAssessments/statistics';
  static String riskStats([String? period]) => '$riskAssessments/statistics';

  // Alert Endpoints
  static const String alerts = '/alerts';

  // Boundary Endpoints
  static const String boundaries = '/boundaries';
  static const String regions = '$boundaries/regions';
  static const String zones = '$boundaries/zones';
  static const String woredas = '$boundaries/woredas';
  static String woredaById(String id) => '$boundaries/woredas/$id';

  // Analytics Endpoints
  static const String analytics = '/analytics';
  static const String dashboard = '$analytics/dashboard';
  static const String regionalBreakdown = '$analytics/regional-breakdown';
  static const String temporalTrends = '$analytics/temporal-trends';
  static const String agronomicAdvisories = '$analytics/agronomic-advisories';

  // Disease Diagnosis Endpoints
  static const String diseaseDiagnosis = '/disease-diagnosis';
  static const String diagnose = '$diseaseDiagnosis/diagnose';
  static String farmDiagnoses(String farmId) => '$diseaseDiagnosis/farm/$farmId';

  // Sensor Endpoints
  static const String sensors = '/sensors';
  static const String telemetry = '$sensors/telemetry';
  static String farmSensors(String farmId) => '$sensors/farm/$farmId';

  // Data Ingestion Endpoints
  static const String ingestion = '/ingestion';
  static const String triggerIngestion = '$ingestion/trigger';
  static const String connectors = '$ingestion/connectors';
  static const String queueStats = '$ingestion/queue/stats';
  static String retryJob(String jobId) => '$ingestion/jobs/$jobId/retry';

  // AI Voice & Speech Endpoints
  static const String aiVoiceInquiry = '/ai/voice-inquiry';
  static const String aiTextInquiry = '/ai/text-inquiry';
  static const String aiSpeakResponse = '/ai/speak';

  // AI Graph Analytics
  static const String analyticsAiInsights = '/analytics/ai-insights';

  // Admin Management Endpoints
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

  // Sensor extended
  static String sensorLatest(String hardwareId) => '/sensors/$hardwareId/latest';
  static String sensorTelemetryHistory(String hardwareId) => '/sensors/$hardwareId/telemetry';

  // Ingestion extended
  static const String ingestionHealth = '$ingestion/health';

  // Email verification
  static const String verifyEmail = '/auth/verify-email';

  // Request timeouts
  static Duration get defaultTimeout => AppEnv.apiTimeout;
  static Duration get longTimeout => AppEnv.longApiTimeout;

  // File upload
  static int get maxFileSizeBytes => AppEnv.maxImageSizeMB * 1024 * 1024;
  static List<String> get allowedImageFormats => AppEnv.allowedImageFormats;
}
