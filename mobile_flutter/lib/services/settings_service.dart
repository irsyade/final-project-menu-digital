import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/services/api_service.dart';

class SettingsService {
  final ApiService _apiService = ApiService();

  // ─── GET settings ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final response = await _apiService.get('/settings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both {"success":true,"data":{...}} and flat {...}
        if (data is Map) {
          if (data['success'] == true && data['data'] is Map) {
            return Map<String, dynamic>.from(data['data'] as Map);
          }
          // Fallback: the response IS the settings object
          if (data.containsKey('site_name') || data.containsKey('primary_color')) {
            return Map<String, dynamic>.from(data);
          }
        }
      }
      debugPrint('getSettings failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('getSettings error: $e');
    }
    return null;
  }

  // ─── SAVE settings ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> saveSettings(
    Map<String, dynamic> data, {
    String? logoPath,
    String? qrisImagePath,
  }) async {
    try {
      // Flatten nested maps into JSON strings for multipart form
      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value == null) return;
        if (value is Map || value is List) {
          fields[key] = jsonEncode(value);
        } else if (value is bool) {
          fields[key] = value ? '1' : '0';
        } else {
          fields[key] = value.toString();
        }
      });

      final files = <String, String>{};
      if (logoPath != null && logoPath.isNotEmpty)      files['site_logo']   = logoPath;
      if (qrisImagePath != null && qrisImagePath.isNotEmpty) files['qris_image'] = qrisImagePath;

      final streamedResponse = await _apiService.postMultipartMultiFiles(
        '/settings',
        fields,
        files: files.isNotEmpty ? files : null,
      );

      final body = await streamedResponse.stream.bytesToString();
      debugPrint('saveSettings [${streamedResponse.statusCode}]: $body');

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final result = jsonDecode(body);
        if (result is Map) {
          if (result['success'] == true && result['data'] is Map) {
            return Map<String, dynamic>.from(result['data'] as Map);
          }
          // Server returned success but different shape — fetch fresh copy
          if (result['success'] == true) {
            return await getSettings();
          }
          // Non-success response
          debugPrint('saveSettings server error: ${result['message']}');
          return null;
        }
      }

      debugPrint('saveSettings HTTP error ${streamedResponse.statusCode}: $body');
      return null;
    } catch (e) {
      debugPrint('saveSettings exception: $e');
      return null;
    }
  }
}
