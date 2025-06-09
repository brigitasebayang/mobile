class AppConfig {
  // IMPORTANT: Ganti dengan IP address komputer Anda
  // Untuk emulator Android: http://10.0.2.2:8000
  // Untuk device fisik: http://192.168.1.XXX:8000 (ganti XXX dengan IP Anda)
  // Untuk iOS simulator: http://localhost:8000
  // Untuk web browser: http://localhost:8000
  
  static const String baseUrl = 'http://localhost:8000'; // Ganti ini untuk web browser
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Untuk Android emulator
  // static const String baseUrl = 'http://192.168.1.100:8000'; // Untuk device fisik (ganti IP)
  
  static const String apiPrefix = '/api';
  static const String mobilePrefix = '/api/mobile';
  
  // Debug Configuration
  static const bool isDebug = true;
  
  // App Configuration
  static const String appName = 'Reusemart';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Cache Configuration
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // Network Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // Helper methods
  static String get fullApiUrl => '$baseUrl$apiPrefix';
  static String get fullMobileApiUrl => '$baseUrl$mobilePrefix';
  
  static void debugPrint(String message) {
    if (isDebug) {
      print('[DEBUG] $message');
    }
  }
  
  static void errorPrint(String message) {
    if (isDebug) {
      print('[ERROR] $message');
    }
  }
  
  static void infoPrint(String message) {
    if (isDebug) {
      print('[INFO] $message');
    }
  }
  
  // Test different URLs based on platform
  static List<String> getTestUrls() {
    return [
      'http://localhost:8000',      // For web browser
      'http://127.0.0.1:8000',      // Alternative localhost
      'http://10.0.2.2:8000',       // Android emulator
      'http://192.168.1.100:8000',  // Local network (change IP)
    ];
  }
}
