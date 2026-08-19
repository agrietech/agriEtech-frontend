import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User roles enumeration
enum UserRole {
  @JsonValue('FARMER')
  farmer,
  @JsonValue('DEVELOPMENT_AGENT')
  developmentAgent,
  @JsonValue('WOREDA_OFFICER')
  woredaOfficer,
  @JsonValue('RESEARCHER')
  researcher,
  @JsonValue('ADMIN')
  admin,
}

/// User model
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String phone,
    String? email,
    required String fullName,
    @JsonKey(name: 'role') required UserRole role,
    String? woredaId,
    @JsonKey(name: 'woreda') WoredaInfo? woreda,
    String? preferredLang,
    @JsonKey(name: 'deviceToken') String? deviceToken,
    @JsonKey(name: 'isActive') @Default(true) bool isActive,
    @JsonKey(name: 'lastLoginAt') DateTime? lastLoginAt,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    @JsonKey(name: 'updatedAt') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Woreda information
@freezed
class WoredaInfo with _$WoredaInfo {
  const factory WoredaInfo({
    required String id,
    required String name,
    String? zoneId,
    @JsonKey(name: 'zone') ZoneInfo? zone,
  }) = _WoredaInfo;

  factory WoredaInfo.fromJson(Map<String, dynamic> json) =>
      _$WoredaInfoFromJson(json);
}

/// Zone information
@freezed
class ZoneInfo with _$ZoneInfo {
  const factory ZoneInfo({
    required String id,
    required String name,
    String? regionId,
    @JsonKey(name: 'region') RegionInfo? region,
  }) = _ZoneInfo;

  factory ZoneInfo.fromJson(Map<String, dynamic> json) =>
      _$ZoneInfoFromJson(json);
}

/// Region information
@freezed
class RegionInfo with _$RegionInfo {
  const factory RegionInfo({
    required String id,
    required String name,
  }) = _RegionInfo;

  factory RegionInfo.fromJson(Map<String, dynamic> json) =>
      _$RegionInfoFromJson(json);
}

/// Login request
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    String? phone,
    String? email,
    String? identifier,
    required String password,
    String? deviceToken,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

/// Login response
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

/// Register request
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String phone,
    required String password,
    required String fullName,
    String? email,
    String? woredaId,
    String? preferredLang,
    String? deviceToken,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

/// Update password request
@freezed
class UpdatePasswordRequest with _$UpdatePasswordRequest {
  const factory UpdatePasswordRequest({
    required String currentPassword,
    required String newPassword,
  }) = _UpdatePasswordRequest;

  factory UpdatePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordRequestFromJson(json);
}

/// Refresh token request
@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}
