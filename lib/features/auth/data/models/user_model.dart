/// Data model representing a villager's profile and Digital Identity status in GramConnect.
class UserProfile {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String villageName;
  final String? wardOrGalli;
  final String pin;
  final String digitalIdStatus; // 'verified', 'pending', 'unverified'
  final String digitalIdCode;
  final String role; // 'villager', 'gram_panchayat', 'admin'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.villageName,
    this.wardOrGalli,
    this.pin = '1234',
    required this.digitalIdStatus,
    required this.digitalIdCode,
    this.role = 'villager',
    required this.createdAt,
  });

  /// Predefined static mock profile representing default villager account
  static final UserProfile mockUser = UserProfile(
    id: 'usr_default_sunita',
    fullName: 'Sunita Tukaram Patil',
    phoneNumber: '9876543210',
    villageName: 'Dhawalpuri Village',
    wardOrGalli: 'Ward No. 2, Maruti Galli',
    pin: '1234',
    digitalIdStatus: 'verified',
    digitalIdCode: 'GC-DHA-94827-VERIFIED',
    role: 'villager',
    createdAt: DateTime(2025, 1, 15),
  );

  /// Default Sarpanch account for demo & administrative review
  static final UserProfile sarpanchUser = UserProfile(
    id: 'usr_sarpanch_thube',
    fullName: 'Ramesh Pandurang Thube',
    phoneNumber: '9422012345',
    villageName: 'Dhawalpuri Village',
    wardOrGalli: 'Gram Panchayat Karyalay',
    pin: '1234',
    digitalIdStatus: 'verified',
    digitalIdCode: 'GC-DHA-00001-SARPANCH',
    role: 'gram_panchayat',
    createdAt: DateTime(2024, 6, 1),
  );

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? villageName,
    String? wardOrGalli,
    String? pin,
    String? digitalIdStatus,
    String? digitalIdCode,
    String? role,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      villageName: villageName ?? this.villageName,
      wardOrGalli: wardOrGalli ?? this.wardOrGalli,
      pin: pin ?? this.pin,
      digitalIdStatus: digitalIdStatus ?? this.digitalIdStatus,
      digitalIdCode: digitalIdCode ?? this.digitalIdCode,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'villageName': villageName,
      'wardOrGalli': wardOrGalli,
      'pin': pin,
      'digitalIdStatus': digitalIdStatus,
      'digitalIdCode': digitalIdCode,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'usr_${json['phoneNumber'] ?? '0000'}',
      fullName: json['fullName'] as String? ?? 'Villager',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      villageName: json['villageName'] as String? ?? 'Dhawalpuri',
      wardOrGalli: json['wardOrGalli'] as String?,
      pin: json['pin'] as String? ?? '1234',
      digitalIdStatus: json['digitalIdStatus'] as String? ?? 'pending',
      digitalIdCode: json['digitalIdCode'] as String? ?? 'GC-DHA-PENDING',
      role: json['role'] as String? ?? 'villager',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
