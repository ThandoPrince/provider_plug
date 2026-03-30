class SPProfileModel {
  final int? id;
  final String? emailAddress;
  final String? mobileNumber;
  final String? isProfileCompleted;
  final bool? isActive;

  SPProfileModel({
    this.id,
    this.emailAddress,
    this.mobileNumber,
    this.isProfileCompleted,
    this.isActive,
  });

  factory SPProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SPProfileModel();

    return SPProfileModel(
      id: json['id'] as int?,
      emailAddress: json['email_address'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      isProfileCompleted: json['is_profile_completed'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email_address': emailAddress,
      'mobile_number': mobileNumber,
      'is_profile_completed': isProfileCompleted,
      'is_active': isActive,
    };
  }
}