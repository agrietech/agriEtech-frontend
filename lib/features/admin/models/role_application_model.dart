import '../../../core/models/user_model.dart';

/// Status of a role application
enum RoleApplicationStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const RoleApplicationStatus(this.value);

  static RoleApplicationStatus fromString(String? val) {
    if (val == null) return RoleApplicationStatus.pending;
    switch (val.toUpperCase()) {
      case 'APPROVED':
        return RoleApplicationStatus.approved;
      case 'REJECTED':
        return RoleApplicationStatus.rejected;
      case 'PENDING':
      default:
        return RoleApplicationStatus.pending;
    }
  }

  String toJson() => value;
}

/// Role upgrade application submitted by a field expert or extension worker
class RoleApplicationModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? userEmail;
  final UserRole currentRole;
  final UserRole requestedRole;
  final String regionId;
  final String regionName;
  final String zoneId;
  final String zoneName;
  final String woredaId;
  final String woredaName;
  final String? kebeleName;
  final String staffIdNumber;
  final String organizationName;
  final RoleApplicationStatus status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const RoleApplicationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userEmail,
    required this.currentRole,
    required this.requestedRole,
    required this.regionId,
    required this.regionName,
    required this.zoneId,
    required this.zoneName,
    required this.woredaId,
    required this.woredaName,
    this.kebeleName,
    required this.staffIdNumber,
    required this.organizationName,
    this.status = RoleApplicationStatus.pending,
    this.rejectionReason,
    this.reviewedBy,
    required this.createdAt,
    this.reviewedAt,
  });

  factory RoleApplicationModel.fromJson(Map<String, dynamic> json) {
    return RoleApplicationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? json['name'] ?? 'Applicant').toString(),
      userPhone: (json['userPhone'] ?? json['phoneNumber'] ?? '').toString(),
      userEmail: json['userEmail'] as String?,
      currentRole: UserRole.fromString(json['currentRole']?.toString()),
      requestedRole: UserRole.fromString(json['requestedRole']?.toString()),
      regionId: (json['regionId'] ?? '').toString(),
      regionName: (json['regionName'] ?? '').toString(),
      zoneId: (json['zoneId'] ?? '').toString(),
      zoneName: (json['zoneName'] ?? '').toString(),
      woredaId: (json['woredaId'] ?? '').toString(),
      woredaName: (json['woredaName'] ?? '').toString(),
      kebeleName: json['kebeleName'] as String?,
      staffIdNumber: (json['staffIdNumber'] ?? json['badgeId'] ?? '').toString(),
      organizationName: (json['organizationName'] ?? json['office'] ?? 'Ministry of Agriculture').toString(),
      status: RoleApplicationStatus.fromString(json['status']?.toString()),
      rejectionReason: json['rejectionReason'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userPhone': userPhone,
    if (userEmail != null) 'userEmail': userEmail,
    'currentRole': currentRole.value,
    'requestedRole': requestedRole.value,
    'regionId': regionId,
    'regionName': regionName,
    'zoneId': zoneId,
    'zoneName': zoneName,
    'woredaId': woredaId,
    'woredaName': woredaName,
    if (kebeleName != null) 'kebeleName': kebeleName,
    'staffIdNumber': staffIdNumber,
    'organizationName': organizationName,
    'status': status.value,
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (reviewedBy != null) 'reviewedBy': reviewedBy,
    'createdAt': createdAt.toIso8601String(),
    if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
  };

  RoleApplicationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    UserRole? currentRole,
    UserRole? requestedRole,
    String? regionId,
    String? regionName,
    String? zoneId,
    String? zoneName,
    String? woredaId,
    String? woredaName,
    String? kebeleName,
    String? staffIdNumber,
    String? organizationName,
    RoleApplicationStatus? status,
    String? rejectionReason,
    String? reviewedBy,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return RoleApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      currentRole: currentRole ?? this.currentRole,
      requestedRole: requestedRole ?? this.requestedRole,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      woredaId: woredaId ?? this.woredaId,
      woredaName: woredaName ?? this.woredaName,
      kebeleName: kebeleName ?? this.kebeleName,
      staffIdNumber: staffIdNumber ?? this.staffIdNumber,
      organizationName: organizationName ?? this.organizationName,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
