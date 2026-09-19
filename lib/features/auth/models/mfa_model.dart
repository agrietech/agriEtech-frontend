/// MFA (Multi-Factor Authentication) Models
library;

class MfaSetupResponse {
  final String secret;
  final String qrCode;
  final List<String> backupCodes;

  const MfaSetupResponse({
    required this.secret,
    required this.qrCode,
    required this.backupCodes,
  });

  factory MfaSetupResponse.fromJson(Map<String, dynamic> json) {
    return MfaSetupResponse(
      secret: json['secret'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      backupCodes: (json['backupCodes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'secret': secret,
        'qrCode': qrCode,
        'backupCodes': backupCodes,
      };
}

class MfaVerifyRequest {
  final String token;

  const MfaVerifyRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

class SessionModel {
  final String id;
  final String device;
  final String? browser;
  final String? os;
  final String? ipAddress;
  final Map<String, dynamic>? location;
  final bool isActive;
  final DateTime lastActivity;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isCurrent;

  const SessionModel({
    required this.id,
    required this.device,
    this.browser,
    this.os,
    this.ipAddress,
    this.location,
    required this.isActive,
    required this.lastActivity,
    required this.expiresAt,
    required this.createdAt,
    this.isCurrent = false,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String? ?? '',
      device: json['device'] as String? ?? 'Unknown Device',
      browser: json['browser'] as String?,
      os: json['os'] as String?,
      ipAddress: json['ipAddress'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'device': device,
        'browser': browser,
        'os': os,
        'ipAddress': ipAddress,
        'location': location,
        'isActive': isActive,
        'lastActivity': lastActivity.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isCurrent': isCurrent,
      };

  String get locationString {
    if (location == null) return ipAddress ?? 'Unknown';
    final city = location!['city'] as String?;
    final country = location!['country'] as String?;
    if (city != null && country != null) return '$city, $country';
    if (country != null) return country;
    return ipAddress ?? 'Unknown';
  }

  String get deviceInfo {
    if (browser != null && os != null) {
      return '$browser on $os';
    }
    if (os != null) return os!;
    if (browser != null) return browser!;
    return device;
  }
}
