class AppConfig {
  // IMPORTANT: Ganti dengan IP address komputer Anda
  // Untuk emulator Android: http://10.0.2.2:8000
  // Untuk device fisik: http://192.168.1.XXX:8000 (ganti XXX dengan IP Anda)
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static const bool isDebug = true;
  
  static void debugPrint(String message) {
    if (isDebug) {
      print('[REUSEMART DEBUG] $message');
    }
  }
}
