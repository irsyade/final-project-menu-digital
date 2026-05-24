// ============================
// auth_controller.dart
// ============================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoggedIn = false.obs;
  var isInitialized = false.obs;
  var user = {}.obs;
  var role = ''.obs;

  bool get isAdmin => role.value == 'admin';
  bool get isKasir => role.value == 'kasir';

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  // ============================
  // CEK LOGIN SAAT APP DIBUKA
  // ============================
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final savedRole = prefs.getString('role');
    final savedUser = prefs.getString('user');

    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
      role.value = (savedRole ?? '').toLowerCase();

      if (savedUser != null && savedUser.isNotEmpty) {
        user.value = jsonDecode(savedUser);
      }
    }

    isInitialized.value = true;
  }

  // ============================
  // LOGIN
  // ============================
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      });

      if (response.body.isEmpty) return false;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        String userRole =
            (data['user']['role'] ?? 'customer').toString().toLowerCase();

        await prefs.setString('token', data['token']);
        await prefs.setString('role', userRole);
        await prefs.setString('user', jsonEncode(data['user']));

        isLoggedIn.value = true;
        user.value = data['user'];
        role.value = userRole;

        debugPrint("LOGIN SUCCESS ROLE: $userRole");

        return true;
      } else {
        Get.snackbar(
          'Login Gagal',
          data['message'] ?? 'Email atau password salah',
        );
        return false;
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      Get.snackbar('Error', 'Tidak bisa terhubung ke server');
      return false;
    }
  }

  // ============================
  // REGISTER
  // ============================
  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      if (response.body.isEmpty) return false;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        String userRole =
            (data['user']['role'] ?? 'customer').toString().toLowerCase();

        await prefs.setString('token', data['token']);
        await prefs.setString('role', userRole);
        await prefs.setString('user', jsonEncode(data['user']));

        isLoggedIn.value = true;
        user.value = data['user'];
        role.value = userRole;

        debugPrint("REGISTER SUCCESS ROLE: $userRole");

        Get.snackbar(
          'Sukses',
          'Register berhasil',
        );
        return true;
      } else {
        Get.snackbar(
          'Register Gagal',
          data['message'] ?? 'Register gagal',
        );
        return false;
      }
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
      Get.snackbar('Error', 'Tidak bisa terhubung ke server');
      return false;
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    isLoggedIn.value = false;
    user.value = {};
    role.value = '';

    Get.offAllNamed('/login');
  }
}