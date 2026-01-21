class SpLiveLocationPostModel {
  final String email;
  final double latitude;
  final double longitude;

  SpLiveLocationPostModel({
    required this.email,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "latitude": latitude.toString(),  
      "longitude": longitude.toString()
    };
  }
}
