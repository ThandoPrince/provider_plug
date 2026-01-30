import 'session_model.dart';

class RatingModel {
  int? id;
  SessionModel? session;
  String? score; // keep as String if API returns "5"
  String? review;
  DateTime? createdAt;

  RatingModel({
    this.id,
    this.session,
    this.score,
    this.review,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RatingModel();

    return RatingModel(
      id: json['id'],
      session: json['session'] != null
          ? SessionModel.fromJson(json['session'])
          : null,
      score: json['score']?.toString(),
      review: json['review'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': session?.toJson(),
      'score': score,
      'review': review,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
