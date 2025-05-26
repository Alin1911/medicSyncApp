import 'dart:convert';
import 'package:http/http.dart' as http;
import './auth_service.dart';

class UserService {
  final String _baseUrl = "http://10.0.2.2:8001/api"; // pentru emulator Android

  Future<Map<String, dynamic>> getProfile() async {
    final String? token = await AuthService.getToken();
    if (token == null) throw Exception('User not logged in');
    final response = await http.get(
      Uri.parse("$_baseUrl/me"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load profile (${response.statusCode}): ${response.body}");
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final String? token = await AuthService.getToken();
    if (token == null) throw Exception('User not logged in');
    final response = await http.put(
      Uri.parse("$_baseUrl/me"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to update profile (${response.statusCode}): ${response.body}");
    }
  }
}
