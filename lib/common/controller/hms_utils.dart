import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';

Future<bool> isHmsAvailable() async {
  try {
    final result = await isHmsAvailable();
    return result == true; // 0 = success (HMS available)
  } catch (_) {
    return false;
  }
}
