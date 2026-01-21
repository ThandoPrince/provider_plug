class ServiceGroupModel {
  final String? groupId;
  final String? name;

  ServiceGroupModel({
    this.groupId,
    this.name,
  });

  factory ServiceGroupModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceGroupModel();

    return ServiceGroupModel(
      groupId: json['group_id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
    };
  }
}
