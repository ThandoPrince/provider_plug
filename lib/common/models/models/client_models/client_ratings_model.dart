import 'package:intl/intl.dart';

class ClientRatingModel {
  final int? id;
  final int? score;
  final String? review;
  final DateTime? createdAt;

  ClientRatingModel({
    this.id,
    this.score,
    this.review,
    this.createdAt,
  });

  factory ClientRatingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientRatingModel();
    }

    return ClientRatingModel(
      id: json['id'] as int?,
      score: json['score'] as int?,
      review: json['review'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'score': score,
        'review': review,
        'created_at': createdAt?.toIso8601String(),
      };

  String get formattedDate =>
      createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt!) : '';
}