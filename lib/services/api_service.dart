import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static String? _token;
  
  static void setToken(String token) {
    _token = token;
  }
  
  static void clearToken() {
    _token = null;
  }
  
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // ========================================
  // AUTHENTICATION METHODS
  // ========================================
  
  static Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    AppConfig.debugPrint('=== API LOGIN REQUEST ===');
    AppConfig.debugPrint('URL: ${AppConfig.fullMobileApiUrl}/login');
    AppConfig.debugPrint('Email: $email');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.fullMobileApiUrl}/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.requestTimeout);

      AppConfig.debugPrint('Response status: ${response.statusCode}');
      AppConfig.debugPrint('Response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Login successful',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Login failed',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Login error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> userData) async {
    AppConfig.debugPrint('=== API REGISTER REQUEST ===');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.fullMobileApiUrl}/register'),
        headers: _headers,
        body: jsonEncode(userData),
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: responseData['message'] ?? 'Registration successful',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Register error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<bool> logout() async {
    AppConfig.debugPrint('=== API LOGOUT REQUEST ===');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.fullMobileApiUrl}/logout'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      AppConfig.debugPrint('Logout response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppConfig.errorPrint('Logout error: $e');
      return false;
    }
  }

  static Future<ApiResponse<User>> getUserProfile() async {
    AppConfig.debugPrint('=== API GET USER PROFILE ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullMobileApiUrl}/user'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      AppConfig.debugPrint('Profile response status: ${response.statusCode}');
      AppConfig.debugPrint('Profile response body: ${response.body}');
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final user = User.fromJson(responseData['data']['user']);
        return ApiResponse<User>(
          success: true,
          message: 'Profile retrieved successfully',
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get profile error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // PRODUCT METHODS
  // ========================================
  
  static Future<ApiResponse<PaginatedResponse<Product>>> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    int? kategoriId,
    String? kondisi,
    double? minHarga,
    double? maxHarga,
  }) async {
    AppConfig.debugPrint('=== API GET PRODUCTS ===');
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (kategoriId != null) {
        queryParams['kategori_id'] = kategoriId.toString();
      }
      if (kondisi != null && kondisi.isNotEmpty) {
        queryParams['kondisi'] = kondisi;
      }
      if (minHarga != null) {
        queryParams['min_harga'] = minHarga.toString();
      }
      if (maxHarga != null) {
        queryParams['max_harga'] = maxHarga.toString();
      }
      
      final uri = Uri.parse('${AppConfig.fullApiUrl}/barang').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final paginatedProducts = PaginatedResponse<Product>.fromJson(
          responseData, 
          (json) => Product.fromJson(json)
        );
        
        return ApiResponse<PaginatedResponse<Product>>(
          success: true,
          message: 'Products retrieved successfully',
          data: paginatedProducts,
        );
      } else {
        return ApiResponse<PaginatedResponse<Product>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get products',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get products error: $e');
      return ApiResponse<PaginatedResponse<Product>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Product>> getProduct(int barangId) async {
    AppConfig.debugPrint('=== API GET PRODUCT $barangId ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullApiUrl}/barang/$barangId'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final product = Product.fromJson(responseData['data']);
        return ApiResponse<Product>(
          success: true,
          message: 'Product retrieved successfully',
          data: product,
        );
      } else {
        return ApiResponse<Product>(
          success: false,
          message: responseData['message'] ?? 'Failed to get product',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get product error: $e');
      return ApiResponse<Product>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // CART METHODS
  // ========================================
  
  static Future<ApiResponse<List<CartItem>>> getCartItems() async {
    AppConfig.debugPrint('=== API GET CART ITEMS ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullApiUrl}/keranjang-belanja'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final cartItems = (responseData['data'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        
        return ApiResponse<List<CartItem>>(
          success: true,
          message: 'Cart items retrieved successfully',
          data: cartItems,
        );
      } else {
        return ApiResponse<List<CartItem>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get cart items',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get cart items error: $e');
      return ApiResponse<List<CartItem>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<CartItem>> addToCart(int barangId, int jumlah) async {
    AppConfig.debugPrint('=== API ADD TO CART ===');
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.fullApiUrl}/keranjang-belanja'),
        headers: _headers,
        body: jsonEncode({
          'barang_id': barangId,
          'jumlah': jumlah,
        }),
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201) {
        final cartItem = CartItem.fromJson(responseData['data']);
        return ApiResponse<CartItem>(
          success: true,
          message: responseData['message'] ?? 'Item added to cart',
          data: cartItem,
        );
      } else {
        return ApiResponse<CartItem>(
          success: false,
          message: responseData['message'] ?? 'Failed to add item to cart',
          errors: responseData['errors'],
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Add to cart error: $e');
      return ApiResponse<CartItem>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<bool>> removeFromCart(int keranjangId) async {
    AppConfig.debugPrint('=== API REMOVE FROM CART ===');
    
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.fullApiUrl}/keranjang-belanja/$keranjangId'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ApiResponse<bool>(
          success: true,
          message: 'Item removed from cart',
          data: true,
        );
      } else {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse<bool>(
          success: false,
          message: responseData['message'] ?? 'Failed to remove item from cart',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Remove from cart error: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // TRANSACTION METHODS
  // ========================================
  
  static Future<ApiResponse<PaginatedResponse<Transaction>>> getTransactions({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    AppConfig.debugPrint('=== API GET TRANSACTIONS ===');
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      final uri = Uri.parse('${AppConfig.fullApiUrl}/transaksi').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final paginatedTransactions = PaginatedResponse<Transaction>.fromJson(
          responseData, 
          (json) => Transaction.fromJson(json)
        );
        
        return ApiResponse<PaginatedResponse<Transaction>>(
          success: true,
          message: 'Transactions retrieved successfully',
          data: paginatedTransactions,
        );
      } else {
        return ApiResponse<PaginatedResponse<Transaction>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get transactions',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get transactions error: $e');
      return ApiResponse<PaginatedResponse<Transaction>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Transaction>> getTransaction(int transaksiId) async {
    AppConfig.debugPrint('=== API GET TRANSACTION $transaksiId ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullApiUrl}/transaksi/$transaksiId'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final transaction = Transaction.fromJson(responseData['data']);
        return ApiResponse<Transaction>(
          success: true,
          message: 'Transaction retrieved successfully',
          data: transaction,
        );
      } else {
        return ApiResponse<Transaction>(
          success: false,
          message: responseData['message'] ?? 'Failed to get transaction',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get transaction error: $e');
      return ApiResponse<Transaction>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // CATEGORY METHODS
  // ========================================
  
  static Future<ApiResponse<List<Category>>> getCategories() async {
    AppConfig.debugPrint('=== API GET CATEGORIES ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullApiUrl}/kategori-barang'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final categories = (responseData['data'] as List)
            .map((item) => Category.fromJson(item))
            .toList();
        
        return ApiResponse<List<Category>>(
          success: true,
          message: 'Categories retrieved successfully',
          data: categories,
        );
      } else {
        return ApiResponse<List<Category>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get categories',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get categories error: $e');
      return ApiResponse<List<Category>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // DASHBOARD METHODS
  // ========================================
  
  static Future<ApiResponse<Map<String, dynamic>>> getDashboardData() async {
    AppConfig.debugPrint('=== API GET DASHBOARD DATA ===');
    
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.fullMobileApiUrl}/dashboard'),
        headers: _headers,
      ).timeout(AppConfig.requestTimeout);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Dashboard data retrieved successfully',
          data: responseData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: responseData['message'] ?? 'Failed to get dashboard data',
        );
      }
    } catch (e) {
      AppConfig.errorPrint('Get dashboard data error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================
  
  static Future<bool> testConnection() async {
    AppConfig.debugPrint('=== API TEST CONNECTION ===');
    AppConfig.debugPrint('Testing URL: ${AppConfig.baseUrl}');
    
    try {
      final response = await http.get(
        Uri.parse(AppConfig.baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      AppConfig.debugPrint('Test connection status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppConfig.errorPrint('Connection test failed: $e');
      return false;
    }
  }
}
