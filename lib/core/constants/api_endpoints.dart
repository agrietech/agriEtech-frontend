///
/// @file api_endpoints.dart
/// @description Centralized REST API endpoint constants aligned with backend v1 API_SPECIFICATION.md.
/// Updated: 2026-08-21
///
library api_endpoints;

import 'api_constants.dart';

class ApiEndpoints {
  // ── Authentication (/auth) ──────────────────────────────────────────────────────────
  static const String login = ApiConstants.login;
  static const String register = ApiConstants.register;
  static const String logout = ApiConstants.logout;
  static const String refreshToken = ApiConstants.refreshToken;
  static const String profile = ApiConstants.profile;
  static const String forgotPassword = ApiConstants.forgotPassword;
  static const String resetPassword = ApiConstants.resetPassword;
  static const String verifyEmail = ApiConstants.verifyEmail;
  static const String resendVerification = ApiConstants.resendVerification;
  static const String updatePassword = ApiConstants.updatePassword;

  // ── Boundaries (/boundaries) ──────────────────────────────────────────────────────────
  static const String boundaries = ApiConstants.boundaries;
  static const String regions = ApiConstants.regions;
  static const String zones = ApiConstants.zones;
  static const String woredas = ApiConstants.woredas;
  static String woredaById(String id) => ApiConstants.woredaById(id);

  // ── Farms (/farms) ───────────────────────────────────────────────────────────────────
  static const String farms = ApiConstants.farms;
  static String farmById(String id) => ApiConstants.farmById(id);

  // ── Sensors (/sensors) ─────────────────────────────────────────────────────────────────
  static const String sensors = ApiConstants.sensors;
  static const String telemetry = ApiConstants.telemetry;
  static String farmSensors(String farmId) => ApiConstants.farmSensors(farmId);
  static String sensorLatest(String hardwareId) => ApiConstants.sensorLatest(hardwareId);
  static String sensorTelemetryHistory(String hardwareId) => ApiConstants.sensorTelemetryHistory(hardwareId);

  // ── Satellite Observations (/satellite-observations) ──────────────────────────────────
  static const String satelliteObservations = ApiConstants.satelliteObservations;
  static String satelliteWoreda(String woredaId) => ApiConstants.satelliteWoreda(woredaId);
  static const String satelliteIngest = ApiConstants.satelliteIngest;

  // ── Risk Assessments (/risk-assessments) ────────────────────────────────────────
  static const String riskAssessments = ApiConstants.riskAssessments;
  static const String evaluateRisk = ApiConstants.evaluateRisk;
  static const String riskStatistics = ApiConstants.riskStatistics;
  static String riskByWoreda(String woredaId) => ApiConstants.riskByWoreda(woredaId);

  // ── Alerts (/alerts) ──────────────────────────────────────────────────────────────────
  static const String alerts = ApiConstants.alerts;
  static String alertById(String id) => ApiConstants.alertById(id);
  static String alertMarkRead(String id) => ApiConstants.alertMarkRead(id);

  // ── Disease Diagnosis (/disease-diagnosis) ────────────────
  static const String diseaseDiagnosis = ApiConstants.diseaseDiagnosis;
  static const String diagnose = ApiConstants.diagnose;
  static String farmDiagnoses(String farmId) => ApiConstants.farmDiagnoses(farmId);

  // ── Analytics (/analytics) ───────────────────────────────────────────────────────
  static const String analytics = ApiConstants.analytics;
  static const String analyticsDashboard = ApiConstants.dashboard;
  static const String analyticsRegionalBreakdown = ApiConstants.regionalBreakdown;
  static const String analyticsTemporalTrends = ApiConstants.temporalTrends;
  static const String analyticsAgronomicAdvisories = ApiConstants.agronomicAdvisories;
  static const String analyticsAiInsights = ApiConstants.analyticsAiInsights;

  // ── Location-Based Map & Analytics (/analytics/location) ───────────────────────────
  static const String locationMap = ApiConstants.locationMap;
  static const String locationAnalytics = ApiConstants.locationAnalytics;
  static String regionMap(String regionId) => ApiConstants.regionMap(regionId);
  static String regionAnalytics(String regionId) => ApiConstants.regionAnalytics(regionId);
  static String zoneMap(String zoneId) => ApiConstants.zoneMap(zoneId);
  static String zoneAnalytics(String zoneId) => ApiConstants.zoneAnalytics(zoneId);
  static String woredaMap(String woredaId) => ApiConstants.woredaMap(woredaId);
  static String woredaAnalytics(String woredaId) => ApiConstants.woredaAnalytics(woredaId);

  // ── AI Voice / Speech (/ai) ───────────────────────────────────
  static const String aiVoiceInquiry = ApiConstants.aiVoiceInquiry;
  static const String aiTextInquiry = ApiConstants.aiTextInquiry;
  static const String aiSpeakResponse = ApiConstants.aiSpeakResponse;
  static const String aiTextToSpeech = ApiConstants.aiTextToSpeech;

  // ── Data Ingestion (/ingestion) ──────────────────────────────────────────
  static const String ingestion = ApiConstants.ingestion;
  static const String triggerIngestion = ApiConstants.triggerIngestion;
  static const String connectors = ApiConstants.connectors;
  static const String ingestionHealth = ApiConstants.ingestionHealth;
  static const String ingestionPull = ApiConstants.ingestionPull;
  static const String ingestionTelemetry = ApiConstants.ingestionTelemetry;
  static const String queueStats = ApiConstants.queueStats;

  // ── USSD Gateway (/delivery/ussd) ─────────────────────────────────────────
  static const String ussdGateway = ApiConstants.ussdGateway;

  // ── Admin (/admin) ────────────────────────────────────────────────────────
  static const String adminOverview = ApiConstants.adminOverview;
  static const String adminUsers = ApiConstants.adminUsers;
  static String adminUserById(String id) => ApiConstants.adminUserById(id);
  static String adminUserRole(String id) => ApiConstants.adminUserRole(id);
  static String adminUserStatus(String id) => ApiConstants.adminUserStatus(id);
  static const String adminFarms = ApiConstants.adminFarms;
  static String adminFarmById(String id) => ApiConstants.adminFarmById(id);
  static const String adminSensors = ApiConstants.adminSensors;
  static String adminSensorById(String id) => ApiConstants.adminSensorById(id);
  static const String adminAlerts = ApiConstants.adminAlerts;
  static String adminAlertById(String id) => ApiConstants.adminAlertById(id);
  static const String adminBroadcastAlert = ApiConstants.adminBroadcastAlert;
  static const String adminDiagnoses = ApiConstants.adminDiagnoses;
  static String adminDiagnosisById(String id) => ApiConstants.adminDiagnosisById(id);
  static const String adminSystemHealth = ApiConstants.adminSystemHealth;
  static const String adminIngestionTrigger = ApiConstants.adminIngestionTrigger;
  static const String adminAuditLogs = ApiConstants.adminAuditLogs;
}
