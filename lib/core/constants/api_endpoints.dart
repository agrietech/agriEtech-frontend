///
/// @file api_endpoints.dart
/// @description Centralized REST API endpoint constants aligned with backend v1.
/// Updated: 2026-08-18
///
library api_endpoints;

class ApiEndpoints {
  // ── Authentication ──────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String updatePassword = '/auth/update-password';

  // ── Boundaries ──────────────────────────────────────────────────────────────
  static const String boundaries = '/boundaries';
  static const String regions = '/boundaries/regions';
  static const String zones = '/boundaries/zones';
  static const String woredas = '/boundaries/woredas';
  static String woredaById(String id) => '/boundaries/woredas/$id';

  // ── Farms ───────────────────────────────────────────────────────────────────
  static const String farms = '/farms';
  static String farmById(String id) => '/farms/$id';

  // ── Sensors ─────────────────────────────────────────────────────────────────
  static const String sensors = '/sensors';
  static const String telemetry = '/sensors/telemetry';
  static String farmSensors(String farmId) => '/sensors/farm/$farmId';

  // ── Satellite Observations ──────────────────────────────────────────────────
  static const String satelliteObservations = '/satellite-observations';

  // ── Risk Assessments ────────────────────────────────────────────────────────
  static const String riskAssessments = '/risk-assessments';
  static const String evaluateRisk = '/risk-assessments/evaluate';
  static String riskByWoreda(String woredaId) => '/risk-assessments/woreda/$woredaId';

  // ── Alerts ──────────────────────────────────────────────────────────────────
  static const String alerts = '/alerts';

  // ── Disease Diagnosis (Dual-AI: Plant.id + Gemini 2.5 Flash) ────────────────
  static const String diseaseDiagnosis = '/disease-diagnosis';
  static const String diagnose = '/disease-diagnosis/diagnose';
  static String farmDiagnoses(String farmId) => '/disease-diagnosis/farm/$farmId';

  // ── Analytics ───────────────────────────────────────────────────────────────
  static const String analytics = '/analytics';
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String analyticsRegionalBreakdown = '/analytics/regional-breakdown';
  static const String analyticsTemporalTrends = '/analytics/temporal-trends';
  static const String analyticsAgronomicAdvisories = '/analytics/agronomic-advisories';
  static const String analyticsAiInsights = '/analytics/ai-insights';

  // ── AI Voice / Speech (Amharic & English) ───────────────────────────────────
  static const String aiVoiceInquiry = '/ai/voice-inquiry';
  static const String aiTextInquiry = '/ai/text-inquiry';
  static const String aiSpeakResponse = '/ai/speak';

  // ── Data Ingestion ──────────────────────────────────────────────────────────
  static const String ingestion = '/ingestion';
  static const String triggerIngestion = '/ingestion/trigger';
  static const String connectors = '/ingestion/connectors';
  static const String queueStats = '/ingestion/queue/stats';
}
