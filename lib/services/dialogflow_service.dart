import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

class DialogflowService {
  late Map<String, dynamic> _credentials;
  String? _accessToken;
  DateTime? _tokenExpiry;
  
  Future<void> initialize() async {
    try {
      _credentials = await getCredentials();
      await _getAccessToken();
    } catch (e) {
      print('Error initializing Dialogflow: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCredentials() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/mughtarib-feb40-65f5014b2b6d.json');
      return json.decode(jsonString);
    } catch (e) {
      print('Error loading credentials: $e');
      throw Exception('فشل في تحميل بيانات الاعتماد');
    }
  }

  Future<void> _getAccessToken() async {
    try {
      final now = DateTime.now();
      if (_accessToken != null && _tokenExpiry != null && now.isBefore(_tokenExpiry!)) {
        return;
      }

      final url = Uri.parse('https://oauth2.googleapis.com/token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': _generateJWT(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = now.add(Duration(seconds: data['expires_in']));
      } else {
        throw Exception('فشل في الحصول على access token');
      }
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  String _generateJWT() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final claims = {
      'iss': _credentials['client_email'],
      'scope': 'https://www.googleapis.com/auth/dialogflow',
      'aud': 'https://oauth2.googleapis.com/token',
      'exp': now + 3600,
      'iat': now,
    };

    final builder = JsonWebSignatureBuilder();
    builder.jsonContent = claims;
    builder.addRecipient(
      JsonWebKey.fromJson({
        'kty': 'RSA',
        'use': 'sig',
        'kid': _credentials['private_key_id'],
        'n': _credentials['private_key'],
        'e': 'AQAB',
      }),
      algorithm: 'RS256',
    );

    return builder.build().toCompactSerialization();
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      await _getAccessToken();
      
      final projectId = _credentials['project_id'];
      final url = Uri.parse(
        'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/123456:detectIntent'
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'queryInput': {
            'text': {
              'text': message,
              'languageCode': 'ar',
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['queryResult']['fulfillmentText'] ?? 'عذراً، لم أفهم سؤالك',
          'intent': data['queryResult']['intent']['displayName'] ?? '',
          'confidence': data['queryResult']['intentDetectionConfidence'] ?? 0.0,
        };
      } else {
        throw Exception('فشل في الاتصال مع Dialogflow');
      }
    } catch (e) {
      print('Error in Dialogflow: $e');
      return {
        'text': 'عذراً، حدث خطأ في التواصل مع المساعد',
        'intent': '',
        'confidence': 0.0,
      };
    }
  }
} 