import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8001/oauth/token';

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json'},
      body: {
        'grant_type': 'password',
        'client_id': '1',
        'client_secret': 'static-secret-key',
        'username': email,
        'password': password,
        'scope': '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      return data['access_token'];
    } else {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null;
  }

  static Future<String?>getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

}

