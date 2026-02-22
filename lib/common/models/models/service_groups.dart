class ServiceCategoryModel {
  final String? categoryId;
  final String? name;
  final String? riskLevel;
  final bool? requiresVerification;
  final bool? requiresAdminApproval;

  ServiceCategoryModel({
    this.categoryId,
    this.name,
    this.riskLevel,
    this.requiresVerification,
    this.requiresAdminApproval,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceCategoryModel();
    return ServiceCategoryModel(
      categoryId: json['category_id']?.toString(),
      name: json['name']?.toString(),
      riskLevel: json['risk_level']?.toString(),
      requiresVerification: json['requires_verification'] as bool?,
      requiresAdminApproval: json['requires_admin_approval'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (requiresVerification != null) 'requires_verification': requiresVerification,
      if (requiresAdminApproval != null) 'requires_admin_approval': requiresAdminApproval,
    };
  }
}

class ServiceGroupModel {
  final String? groupId;
  final String? name;
  final ServiceCategoryModel? category; 

  ServiceGroupModel({
    this.groupId,
    this.name,
    this.category,
  });

  factory ServiceGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceGroupModel();

    return ServiceGroupModel(
      groupId: json['group_id']?.toString(),
      name: json['name']?.toString(),
      // Handle the Foreign Key relationship
      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (category != null) 'category': category?.toJson(),
    };
  }
}