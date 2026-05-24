import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/services/api_service.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
    on<LoginRequestedEvent>(_onLoginRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final savedRole = prefs.getString('role');
      final savedUser = prefs.getString('user');

      if (token != null && token.isNotEmpty) {
        final role = (savedRole ?? '').toLowerCase();
        final user = savedUser != null && savedUser.isNotEmpty
            ? jsonDecode(savedUser)
            : <String, dynamic>{};
            
        // Sync with AuthController (Bridge)
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          authController.isLoggedIn.value = true;
          authController.user.value = user;
          authController.role.value = role;
        }

        emit(AuthAuthenticated(role, user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.post('/login', {
        'email': event.email,
        'password': event.password,
      });

      if (response.body.isEmpty) {
        emit(const AuthFailure('Response is empty'));
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        String userRole = (data['user']['role'] ?? 'customer').toString().toLowerCase();

        await prefs.setString('token', data['token']);
        await prefs.setString('role', userRole);
        await prefs.setString('user', jsonEncode(data['user']));

        // Sync with AuthController (Bridge)
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          authController.isLoggedIn.value = true;
          authController.user.value = data['user'];
          authController.role.value = userRole;
        }

        emit(AuthAuthenticated(userRole, data['user']));
      } else {
        emit(AuthFailure(data['message'] ?? 'Email atau password salah'));
      }
    } catch (e) {
      emit(const AuthFailure('Tidak bisa terhubung ke server'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _apiService.post('/logout', {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Sync with AuthController (Bridge)
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      authController.isLoggedIn.value = false;
      authController.user.value = {};
      authController.role.value = '';
    }

    emit(AuthUnauthenticated());
  }
}
