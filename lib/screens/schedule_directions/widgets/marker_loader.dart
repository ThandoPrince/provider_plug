import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerLoader {
  static Future<BitmapDescriptor> loadMarker(String asset, int size) async {
    final bytes = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    final frame = await codec.getNextFrame();
    final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    // BitmapDescriptor.bytes (google_maps_flutter >= 2.7) lets you specify
    // the intended size so the icon isn't rendered at native pixel density
    // on high-DPI screens. If your pinned version is older, swap this for
    // `BitmapDescriptor.fromBytes(png!.buffer.asUint8List())`.
    return BitmapDescriptor.bytes(
      png!.buffer.asUint8List(),
      width: size.toDouble(),
      height: size.toDouble(),
    );
  }
}