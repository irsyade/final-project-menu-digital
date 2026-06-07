import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      });

      debugPrint("LOGIN RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.body.isEmpty) return {"success": false, "message": "Server tidak merespon (empty response)"};

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "token": data['token'],
          "user": data['user'],
          "role": (data['user']['role'] ?? 'customer').toString().toLowerCase(),
        };
      } else if (response.statusCode == 422) {
        // Validation error
        final errors = data['errors'];
        if (errors != null && errors is Map) {
          final firstError = (errors.values.first as List).first;
          return {"success": false, "message": firstError.toString()};
        }
        return {"success": false, "message": data['message'] ?? 'Validasi gagal'};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Login gagal (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint("AUTH SERVICE LOGIN ERROR: $e");
      return {"success": false, "message": "Tidak bisa terhubung ke server: $e"};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      debugPrint("REGISTER RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.body.isEmpty) return {"success": false, "message": "Server tidak merespon (empty response)"};

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "token": data['token'],
          "user": data['user'],
          "role": (data['user']['role'] ?? 'customer').toString().toLowerCase(),
        };
      } else if (response.statusCode == 422) {
        // Validation error (e.g. email already taken)
        final errors = data['errors'];
        if (errors != null && errors is Map) {
          final firstError = (errors.values.first as List).first;
          return {"success": false, "message": firstError.toString()};
        }
        return {"success": false, "message": data['message'] ?? 'Validasi gagal'};
      } else if (response.statusCode == 500) {
        return {"success": false, "message": "Server error (500). Periksa konfigurasi server."};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Register gagal (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint("AUTH SERVICE REGISTER ERROR: $e");
      return {"success": false, "message": "Tidak bisa terhubung ke server: $e"};
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } catch (_) {}
  }
}
