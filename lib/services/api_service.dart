import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5087/api';  // For Android Emulator
  // static const String baseUrl = 'http://localhost:5087/api';  // For iOS Simulator
  String? _token;
  int? _userId;
  DateTime? _tokenExpiry;

  // Initialize token and userID on app start
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      if (_token != null) {
        _userId = _getUserIdFromToken(_token!);
        _tokenExpiry = _getTokenExpiry(_token!);
      }
    } catch (e) {
      print('Error initializing ApiService: $e');
      _token = null;
      _userId = null;
      _tokenExpiry = null;
    }
  }

  // Get userID from token
  int? _getUserIdFromToken(String token) {
    try {
      if (!JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);
        final sub = decodedToken['sub'] as String?;
        if (sub != null) {
          return int.tryParse(sub);
        }
      }
      return null;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  // Get token expiry from token
  DateTime? _getTokenExpiry(String token) {
    try {
      if (!JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);
        final exp = decodedToken['exp'] as int?;
        if (exp != null) {
          return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        }
      }
      return null;
    } catch (e) {
      print('Error getting token expiry: $e');
      return null;
    }
  }

  // Get request headers with token
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Get current userID
  int? get userId => _userId;

  // Check if user is logged in
  bool get isLoggedIn => _token != null && _userId != null && !_isTokenExpired();

  // Check if token is expired
  bool _isTokenExpired() {
    return _tokenExpiry == null || _tokenExpiry!.isBefore(DateTime.now());
  }

  // Generic HTTP methods with error handling
  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      if (_isTokenExpired()) {
        await _refreshToken();
      }
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      if (_isTokenExpired()) {
        await _refreshToken();
      }
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      if (_isTokenExpired()) {
        await _refreshToken();
      }
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      if (_isTokenExpired()) {
        await _refreshToken();
      }
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Refresh token
  Future<void> _refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': _token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = _getUserIdFromToken(_token!);
        _tokenExpiry = _getTokenExpiry(_token!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
      } else {
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await logout();
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> login(int userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = _getUserIdFromToken(_token!);
        _tokenExpiry = _getTokenExpiry(_token!);

        if (_userId == null) {
          throw Exception('Invalid token received');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      _token = null;
      _userId = null;
      _tokenExpiry = null;
      throw Exception('Login failed: $e');
    }
  }

  // Register new student
  Future<Map<String, dynamic>> registerStudent({
    required int userID,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Students'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userID': userID,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'password': password,
          'email': email,
          'role': '',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Get student profile
  Future<Map<String, dynamic>> getStudentProfile() async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Students/$_userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update student profile
  Future<Map<String, dynamic>> updateStudentProfile(
    int userId,
    Map<String, dynamic> studentData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Students/$userId'),
        headers: _headers,
        body: jsonEncode(studentData),
      );

      if (response.statusCode == 200) {
    return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Delete student account
  Future<void> deleteStudentAccount(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Students/$userId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _token = null;
      _userId = null;
      _tokenExpiry = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      print('Error during logout: $e');
      // Continue with logout even if there's an error
      _token = null;
      _userId = null;
      _tokenExpiry = null;
    }
  }
  Future<List<Student>> fetchStudents() async {
    final token = _token;
    final url = Uri.parse('$baseUrl/api/Students');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }
}

