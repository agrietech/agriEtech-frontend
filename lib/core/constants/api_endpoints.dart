///
/// @file api_endpoints.dart
/// @description Centralized REST API endpoint constants.
/// @author Frontend Core
///
library api_endpoints;

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String boundaries = '/boundaries';
  static const String regions = '/boundaries/regions';
  static const String zones = '/boundaries/zones';
  static const String woredas = '/boundaries/woredas';
  static const String farms = '/farms';
  static const String sensors = '/sensors';
  static const String satelliteObservations = '/satellite-observations';
  static const String riskAssessments = '/risk-assessments';
  static const String alerts = '/alerts';
  static const String diseaseDiagnosis = '/disease-diagnosis';
  static const String analytics = '/analytics';
}
