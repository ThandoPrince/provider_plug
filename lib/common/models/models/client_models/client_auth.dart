class ClientAuthModel {
  final int? id;

  ClientAuthModel({this.id});

  factory ClientAuthModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAuthModel();
    }

    return ClientAuthModel(
      id: json['id'] as int?,
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      
    };
  }
}
