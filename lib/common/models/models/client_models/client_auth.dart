class ClientAuthModel {
  final String? emailAddress;
  final String? mobileNumber;
  final String? password;

  ClientAuthModel({
    this.emailAddress,
    this.mobileNumber,
    this.password,
  });

  factory ClientAuthModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAuthModel();
    }

    return ClientAuthModel(
      emailAddress: json['email_address'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_address': emailAddress,
      'mobile_number': mobileNumber,
      'password': password,
    };
  }
}
