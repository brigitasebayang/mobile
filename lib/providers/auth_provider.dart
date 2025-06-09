import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  User? _user;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    AppConfig.debugPrint('AuthProvider initialized');
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    AppConfig.debugPrint('Checking login status...');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      
      AppConfig.debugPrint('Stored token: ${storedToken != null ? 'Found' : 'Not found'}');
      
      if (storedToken != null) {
        _token = storedToken;
        ApiService.setToken(storedToken);
        
        // Validate token with server
        final response = await AuthService.getUserProfile(storedToken);
        if (response.success && response.data != null) {
          _user = response.data!;
          _isAuthenticated = true;
          AppConfig.debugPrint('User authenticated: ${_user!.email}');
        } else {
          AppConfig.debugPrint('Token validation failed: ${response.message}');
          await _clearAuthData();
        }
      }
    } catch (e) {
      AppConfig.debugPrint('Error checking login status: $e');
      await _clearAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    AppConfig.debugPrint('Attempting login for: $email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      AppConfig.debugPrint('Login response: ${response.success}');
      
      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final token = response.data!['access_token'] as String;
        
        _token = token;
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        
        // Set token for future API calls
        ApiService.setToken(token);
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        AppConfig.debugPrint('Login successful for: ${_user!.email}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        AppConfig.debugPrint('Login failed: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      AppConfig.debugPrint('Login error: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    AppConfig.debugPrint('Attempting registration for: $email');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.register(name, email, password);
      AppConfig.debugPrint('Register response: ${response.success}');
      
      if (response.success && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final token = response.data!['access_token'] as String;
        
        _token = token;
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        
        // Set token for future API calls
        ApiService.setToken(token);
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        AppConfig.debugPrint('Registration successful for: ${_user!.email}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        AppConfig.debugPrint('Registration failed: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      AppConfig.debugPrint('Registration error: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    AppConfig.debugPrint('Logging out...');
    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        await AuthService.logout(_token!);
      }
      
      await _clearAuthData();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      AppConfig.debugPrint('Logout error: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearAuthData() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;
    
    // Clear API service token
    ApiService.clearToken();
    
    // Clear stored token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    AppConfig.debugPrint('Auth data cleared');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_token != null) {
      try {
        final response = await AuthService.getUserProfile(_token!);
        if (response.success && response.data != null) {
          _user = response.data!;
          notifyListeners();
        }
      } catch (e) {
        AppConfig.debugPrint('Error refreshing user data: $e');
      }
    }
  }
}
