

class CostOfServiceModel {
  final int? id;

  final double? basePrice;
  final bool negotiable;
  final String? notes;

  CostOfServiceModel({
    this.id,

    this.basePrice,
    required this.negotiable,
    this.notes,
  });

  factory CostOfServiceModel.fromJson(Map<String, dynamic> json) {
    return CostOfServiceModel(
      id: json['id'],

      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
      negotiable: json['negotiable'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
  
      'base_price': basePrice,
      'negotiable': negotiable,
      'notes': notes,
    };
  }
}
