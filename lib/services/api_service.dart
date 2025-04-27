import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:5087/api/Auth/login";

  // دالة GET عامة
  Future<dynamic> getData(String endpoint, String token) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    return jsonDecode(response.body);
  }

  // يمكنك إضافة دوال POST, PUT, DELETE بالمثل
}
