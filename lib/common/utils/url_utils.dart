  String? getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;

  // Full URL already? Just return it
  if (path.startsWith('http')) return path;

  // Otherwise, prepend your server URL
  return 'http://192.168.18.64:8000$path';
}