import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart' as app_user;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiService _apiService = ApiService();
  app_user.User? _currentUser;
  String? _sessionToken;
  DateTime? _tokenExpiry;

  // Initialize the service
  Future<void> init() async {
    await _apiService.init();
    await _loadSession();
  }

  // Get current user
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  app_user.User? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;

  // Load session from storage
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('session_token');
      final userJson = prefs.getString('current_user');
      final expiry = prefs.getString('token_expiry');

      if (token != null && userJson != null && expiry != null) {
        _sessionToken = token;
        _currentUser = app_user.User.fromJson(jsonDecode(userJson));
        _tokenExpiry = DateTime.parse(expiry);

        if (_isTokenExpired()) {
          await logout();
        } else {
          await _refreshToken();
        }
      }
    } catch (e) {
      print('Error loading session: $e');
      await logout();
    }
  }

  // Save session to storage
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sessionToken != null && _currentUser != null && _tokenExpiry != null) {
        await prefs.setString('session_token', _sessionToken!);
        await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
        await prefs.setString('token_expiry', _tokenExpiry!.toIso8601String());
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Check if token is expired
  bool _isTokenExpired() {
    return _tokenExpiry == null || _tokenExpiry!.isBefore(DateTime.now());
  }

  // Refresh token
  Future<void> _refreshToken() async {
    try {
      final response = await _apiService.post('Auth/refresh', {
        'token': _sessionToken,
      });
      _sessionToken = response['token'];
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
      await _saveSession();
    } catch (e) {
      print('Error refreshing token: $e');
      await logout();
    }
  }

  // Login with university ID and password
  Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionToken = data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        _currentUser = await getUserProfile();
        await _saveSession();
        return {'success': true, 'message': 'تم تسجيل الدخول بنجاح'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'فشل تسجيل الدخول'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء تسجيل الدخول'};
    }
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionToken = data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        _currentUser = await getUserProfile();
        await _saveSession();
        return {'success': true, 'message': 'تم التسجيل بنجاح'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'فشل التسجيل'};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ أثناء التسجيل'};
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _apiService.post('Auth/reset-password', {
        'email': email,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // Get user profile
  Future<app_user.User> getUserProfile() async {
    try {
      final response = await _apiService.get('Students/${_apiService.userId}');
      _currentUser = app_user.User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update user profile
  Future<app_user.User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? profilePicture,
    List<String>? addresses,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (profilePicture != null) data['profilePicture'] = profilePicture;
      if (addresses != null) data['addresses'] = addresses;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _apiService.put('Students/${_apiService.userId}', data);
      _currentUser = app_user.User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _currentUser = null;
      _sessionToken = null;
      _tokenExpiry = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
      await prefs.remove('current_user');
      await prefs.remove('token_expiry');
      await _apiService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Continue with logout even if there's an error
      _currentUser = null;
      _sessionToken = null;
      _tokenExpiry = null;
    }
  }
}
