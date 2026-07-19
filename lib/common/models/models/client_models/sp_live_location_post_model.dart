class SpLiveLocationPostModel {
 
  final double latitude;
  final double longitude;

  SpLiveLocationPostModel({
   
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      
      "latitude": latitude.toString(),  
      "longitude": longitude.toString()
    };
  }
}
