import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:5087";

  Future<String> login(int userID, String password) async {
    final url = Uri.parse("$baseUrl/api/Auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userID": userID, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data["token"];
    } else {
      throw Exception("فشل تسجيل الدخول: ${response.body}");
    }
  }
}
