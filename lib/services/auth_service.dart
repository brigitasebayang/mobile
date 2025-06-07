import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    AppConfig.debugPrint('=== LOGIN REQUEST START ===');
    AppConfig.debugPrint('URL: ${AppConfig.baseUrl}/api/mobile/login');
    AppConfig.debugPrint('Email: $email');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/mobile/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      AppConfig.debugPrint('Response status: ${response.statusCode}');
      AppConfig.debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        AppConfig.debugPrint('Login SUCCESS: $responseData');
        return responseData;
      } else {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        AppConfig.debugPrint('Login FAILED: $responseData');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      AppConfig.debugPrint('Login ERROR: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  static Future<bool> logout(String token) async {
    AppConfig.debugPrint('=== LOGOUT REQUEST START ===');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/mobile/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      AppConfig.debugPrint('Logout response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppConfig.debugPrint('Logout error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String token) async {
    AppConfig.debugPrint('=== GET USER PROFILE START ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/mobile/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      AppConfig.debugPrint('Profile response status: ${response.statusCode}');
      AppConfig.debugPrint('Profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          return responseData['data']['user'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      AppConfig.debugPrint('Get profile error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    AppConfig.debugPrint('=== REGISTER REQUEST START ===');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/mobile/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role_id': 4, // Default to pembeli
          'dob': '1990-01-01', // Default date
        }),
      ).timeout(const Duration(seconds: 30));

      AppConfig.debugPrint('Register response status: ${response.statusCode}');
      AppConfig.debugPrint('Register response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      AppConfig.debugPrint('Register error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Test connection method
  static Future<bool> testConnection() async {
    AppConfig.debugPrint('=== TESTING CONNECTION ===');
    AppConfig.debugPrint('Testing URL: ${AppConfig.baseUrl}');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      AppConfig.debugPrint('Test connection status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppConfig.debugPrint('Connection test failed: $e');
      return false;
    }
  }
}
