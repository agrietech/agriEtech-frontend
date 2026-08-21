/// User and authentication data models (pure Dart without Freezed)
library user_model;

/// User roles enumeration
enum UserRole {
  farmer('FARMER'),
  developmentAgent('DEVELOPMENT_AGENT'),
  woredaOfficer('WOREDA_OFFICER'),
  researcher('RESEARCHER'),
  admin('ADMIN');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.farmer;
    final upper = role.toUpperCase().replaceAll('-', '_').trim();
    switch (upper) {
      case 'DEVELOPMENT_AGENT':
      case 'AGENT':
        return UserRole.developmentAgent;
      case 'WOREDA_OFFICER':
      case 'OFFICER':
        return UserRole.woredaOfficer;
      case 'RESEARCHER':
        return UserRole.researcher;
      case 'ADMIN':
      case 'ADMINISTRATOR':
        return UserRole.admin;
      case 'FARMER':
      default:
        return UserRole.farmer;
    }
  }

  String toJson() => value;
}

/// User model
class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String fullName;
  final UserRole role;
  final String? woredaId;
  final WoredaInfo? woreda;
  final String? preferredLang;
  final String? deviceToken;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    required this.role,
    this.woredaId,
    this.woreda,
    this.preferredLang,
    this.deviceToken,
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role'];
    final role = roleRaw is UserRole
        ? roleRaw
        : UserRole.fromString(roleRaw?.toString());

    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      email: json['email'] as String?,
      fullName: (json['fullName'] ?? json['name'] ?? 'User').toString(),
      role: role,
      woredaId: (json['woredaId'] ?? json['woreda']?['id']) as String?,
      woreda: json['woreda'] is Map<String, dynamic>
          ? WoredaInfo.fromJson(json['woreda'] as Map<String, dynamic>)
          : null,
      preferredLang: json['preferredLang'] as String?,
      deviceToken: json['deviceToken'] as String?,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    if (email != null) 'email': email,
    'fullName': fullName,
    'role': role.value,
    if (woredaId != null) 'woredaId': woredaId,
    if (woreda != null) 'woreda': woreda!.toJson(),
    if (preferredLang != null) 'preferredLang': preferredLang,
    if (deviceToken != null) 'deviceToken': deviceToken,
    'isActive': isActive,
    if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    UserRole? role,
    String? woredaId,
    WoredaInfo? woreda,
    String? preferredLang,
    String? deviceToken,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      woredaId: woredaId ?? this.woredaId,
      woreda: woreda ?? this.woreda,
      preferredLang: preferredLang ?? this.preferredLang,
      deviceToken: deviceToken ?? this.deviceToken,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Woreda information
class WoredaInfo {
  final String id;
  final String name;
  final String? zoneId;
  final ZoneInfo? zone;

  const WoredaInfo({
    required this.id,
    required this.name,
    this.zoneId,
    this.zone,
  });

  factory WoredaInfo.fromJson(Map<String, dynamic> json) {
    return WoredaInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      zoneId: json['zoneId'] as String?,
      zone: json['zone'] is Map<String, dynamic>
          ? ZoneInfo.fromJson(json['zone'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (zoneId != null) 'zoneId': zoneId,
    if (zone != null) 'zone': zone!.toJson(),
  };
}

/// Zone information
class ZoneInfo {
  final String id;
  final String name;
  final String? regionId;
  final RegionInfo? region;

  const ZoneInfo({
    required this.id,
    required this.name,
    this.regionId,
    this.region,
  });

  factory ZoneInfo.fromJson(Map<String, dynamic> json) {
    return ZoneInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      regionId: json['regionId'] as String?,
      region: json['region'] is Map<String, dynamic>
          ? RegionInfo.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (regionId != null) 'regionId': regionId,
    if (region != null) 'region': region!.toJson(),
  };
}

/// Region information
class RegionInfo {
  final String id;
  final String name;

  const RegionInfo({
    required this.id,
    required this.name,
  });

  factory RegionInfo.fromJson(Map<String, dynamic> json) {
    return RegionInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// Login request
class LoginRequest {
  final String? phone;
  final String? email;
  final String? identifier;
  final String password;
  final String? deviceToken;

  const LoginRequest({
    this.phone,
    this.email,
    this.identifier,
    required this.password,
    this.deviceToken,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      identifier: json['identifier'] as String?,
      password: (json['password'] ?? '').toString(),
      deviceToken: json['deviceToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (identifier != null) 'identifier': identifier,
    'password': password,
    if (deviceToken != null) 'deviceToken': deviceToken,
  };
}

/// Login response
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['accessToken'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: UserModel.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };
}

/// Register request
class RegisterRequest {
  final String phone;
  final String password;
  final String fullName;
  final String? email;
  final String? woredaId;
  final String? preferredLang;
  final String? deviceToken;

  const RegisterRequest({
    required this.phone,
    required this.password,
    required this.fullName,
    this.email,
    this.woredaId,
    this.preferredLang,
    this.deviceToken,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: json['email'] as String?,
      woredaId: json['woredaId'] as String?,
      preferredLang: json['preferredLang'] as String?,
      deviceToken: json['deviceToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'phoneNumber': phone,
    'phone': phone,
    'password': password,
    'fullName': fullName,
    'name': fullName,
    if (email != null) 'email': email,
    if (woredaId != null) 'woredaId': woredaId,
    if (preferredLang != null) 'preferredLang': preferredLang,
    if (deviceToken != null) 'deviceToken': deviceToken,
  };
}

/// Update password request
class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory UpdatePasswordRequest.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordRequest(
      currentPassword: (json['currentPassword'] ?? json['oldPassword'] ?? '').toString(),
      newPassword: (json['newPassword'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}

/// Refresh token request
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      refreshToken: (json['refreshToken'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}
