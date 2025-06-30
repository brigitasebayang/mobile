import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return await ApiService.login(email, password);
  }

  static Future<bool> logout(String token) async {
    ApiService.setToken(token);
    final result = await ApiService.logout();
    if (result) {
      ApiService.clearToken();
    }
    return result;
  }

  static Future<ApiResponse<User>> getUserProfile(String token) async {
    ApiService.setToken(token);
    return await ApiService.getUserProfile();
  }

  static Future<ApiResponse<Map<String, dynamic>>> register(String name, String email, String password) async {
    final userData = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role_id': 4, // Default to pembeli
      'dob': '1990-01-01', // Default date
    };
    
    return await ApiService.register(userData);
  }

  // Test connection method
  static Future<bool> testConnection() async {
    return await ApiService.testConnection();
  }
}