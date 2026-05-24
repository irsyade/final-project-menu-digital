import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile_flutter/services/api_service.dart';

class SettingsController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var settings = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/settings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          settings.value = data['data'];
        }
      }
    } catch (e) {
      print('Fetch Settings Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveSettings(Map<String, dynamic> data, {String? logoPath}) async {
    isSaving.value = true;
    try {
      // Convert map to strings for multipart request
      Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value is Map || value is List) {
          fields[key] = jsonEncode(value);
        } else if (value != null) {
          fields[key] = value.toString();
        }
      });

      final response = await _apiService.postMultipart(
        '/settings',
        fields,
        filePath: logoPath,
        fileField: 'site_logo',
      );

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final result = jsonDecode(responseString);
        if (result['success']) {
          settings.value = result['data'];
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Save Settings Error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
