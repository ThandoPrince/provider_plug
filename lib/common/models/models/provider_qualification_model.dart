class ProviderQualificationModel {
  final int? id;
  final int? providerService;
  final String? documentType;
  final String? title;
  final String? issuingBody;
  final String? issueDate;
  final String? expiryDate;
  final String? documentUrl;
  final String? uploadedAt;

  ProviderQualificationModel({
    this.id,
    this.providerService,
    this.documentType,
    this.title,
    this.issuingBody,
    this.issueDate,
    this.expiryDate,
    this.documentUrl,
    this.uploadedAt,
  });

  factory ProviderQualificationModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return ProviderQualificationModel();

    return ProviderQualificationModel(
      id: json["id"],
      providerService: json["provider_service"],
      documentType: json["document_type"],
      title: json["title"],
      issuingBody: json["issuing_body"],
      issueDate: json["issue_date"],
      expiryDate: json["expiry_date"],
      documentUrl: json["document_url"],
      uploadedAt: json["uploaded_at"],
    );
  }

  static List<ProviderQualificationModel> listFromJson(
    List<dynamic>? data,
  ) {
    if (data == null) return [];

    return data
        .map((e) => ProviderQualificationModel.fromJson(e))
        .toList();
  }
}