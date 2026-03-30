
import 'package:get_storage/get_storage.dart'; // use your actual path if different

class Storage {
  static final GetStorage _box = GetStorage();

  bool? getBool(String key) {
    final value = _box.read(key);
    if (value is bool) return value;
    return null;
  }

  Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }

  String? getString(String key) {
    final value = _box.read(key);
    if (value is String) return value;
    return null;
  }

  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }
}