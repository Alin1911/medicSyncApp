import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prescription_models.dart'; 
import './auth_service.dart'; 

class PrescriptionService {
  final String _baseUrl = "http://10.0.2.2:8001/api";

  Future<List<Prescription>> getPrescriptions() async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Failed to load prescriptions: User not logged in or token not found.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prescriptionsJson = data['prescriptions'];
        return prescriptionsJson.map((json) => Prescription.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be invalid or expired
        throw Exception('Failed to load prescriptions: Unauthorized (Token issue - Status code: ${response.statusCode})');
      }
      else {
        throw Exception('Failed to load prescriptions (Status code: ${response.statusCode}) - Body: ${response.body}');
      }
    } catch (e) {
      // Handle network errors or parsing errors
      throw Exception('Failed to load prescriptions: $e');
    }
  }
}