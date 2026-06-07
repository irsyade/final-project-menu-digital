// ============================
// auth_controller.dart
// ============================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

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
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', result['token']);
        await prefs.setString('role', result['role']);
        await prefs.setString('user', jsonEncode(result['user']));

        isLoggedIn.value = true;
        user.value = result['user'];
        role.value = result['role'];

        debugPrint("LOGIN SUCCESS ROLE: ${result['role']}");
        return true;
      } else {
        Get.snackbar(
          'Login Gagal',
          result['message'] ?? 'Email atau password salah',
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
      final result = await _authService.register(name, email, password);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', result['token']);
        await prefs.setString('role', result['role']);
        await prefs.setString('user', jsonEncode(result['user']));

        isLoggedIn.value = true;
        user.value = result['user'];
        role.value = result['role'];

        debugPrint("REGISTER SUCCESS ROLE: ${result['role']}");

        Get.snackbar(
          'Sukses',
          'Register berhasil',
        );
        return true;
      } else {
        Get.snackbar(
          'Register Gagal',
          result['message'] ?? 'Register gagal',
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
    await _authService.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    isLoggedIn.value = false;
    user.value = {};
    role.value = '';

    Get.offAllNamed('/login');
  }
}
