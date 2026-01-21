import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:here_sdk/mapview.dart';

class MarkerLoader {
  static Future<MapImage> loadMarker(String asset, int size) async {
    final bytes = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    final frame = await codec.getNextFrame();
    final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return MapImage.withPixelDataAndImageFormat(png!.buffer.asUint8List(), ImageFormat.png);
  }
}
