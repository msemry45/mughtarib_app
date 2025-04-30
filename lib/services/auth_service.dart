import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  String? _sessionToken;
  DateTime? _tokenExpiry;

  // Initialize the service
  Future<void> init() async {
    await _apiService.init();
    await _loadSession();
  }

  // Get current user
  bool get isLoggedIn => _currentUser != null && _sessionToken != null;
  User? get currentUser => _currentUser;
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
        _currentUser = User.fromJson(jsonDecode(userJson));
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

  // Login
  Future<User> login(int userId, String password) async {
    try {
      final response = await _apiService.login(userId, password);
      _currentUser = User.fromJson(response['user']);
      _sessionToken = response['token'];
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<User> register({
    required int userID,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _apiService.post('Students', {
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'password': password,
        'email': email,
        'role': '',
      });
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get user profile
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get('Students/${_apiService.userId}');
      _currentUser = User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update user profile
  Future<User> updateUserProfile({
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
      _currentUser = User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(String imagePath) async {
    try {
      final response = await _apiService.post('Students/upload-profile-picture', {
        'imagePath': imagePath,
      });
      return response['imageUrl'];
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Add address
  Future<User> addAddress(String address) async {
    try {
      final response = await _apiService.post('Students/add-address', {
        'address': address,
      });
      _currentUser = User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Remove address
  Future<User> removeAddress(String address) async {
    try {
      final response = await _apiService.post('Students/remove-address', {
        'address': address,
      });
      _currentUser = User.fromJson(response);
      await _saveSession();
      return _currentUser!;
    } catch (e) {
      throw Exception('Failed to remove address: $e');
    }
  }

  // Request email verification
  Future<void> requestEmailVerification() async {
    try {
      await _apiService.post('Auth/request-email-verification', {});
    } catch (e) {
      throw Exception('Failed to request email verification: $e');
    }
  }

  // Verify email
  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post('Auth/verify-email', {'token': token});
      _currentUser = _currentUser?.copyWith(isEmailVerified: true);
      await _saveSession();
    } catch (e) {
      throw Exception('Failed to verify email: $e');
    }
  }

  // Request phone verification
  Future<void> requestPhoneVerification() async {
    try {
      await _apiService.post('Auth/request-phone-verification', {});
    } catch (e) {
      throw Exception('Failed to request phone verification: $e');
    }
  }

  // Verify phone
  Future<void> verifyPhone(String code) async {
    try {
      await _apiService.post('Auth/verify-phone', {'code': code});
      _currentUser = _currentUser?.copyWith(isPhoneVerified: true);
      await _saveSession();
    } catch (e) {
      throw Exception('Failed to verify phone: $e');
    }
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.post('Auth/request-password-reset', {'email': email});
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiService.post('Auth/reset-password', {
        'token': token,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post('Auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    try {
      await _apiService.delete('Students/${_apiService.userId}');
      await logout();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
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
