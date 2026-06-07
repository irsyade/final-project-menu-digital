import 'package:get/get.dart';
import 'package:mobile_flutter/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = SettingsService();

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
      final data = await _settingsService.getSettings();
      if (data != null) {
        settings.value = data;
      }
    } catch (e) {
      print('Fetch Settings Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Alias method for loadSettings
  Future<void> loadSettings() => fetchSettings();

  Future<bool> saveSettings(Map<String, dynamic> data, {String? logoPath, String? qrisImagePath}) async {
    isSaving.value = true;
    try {
      final resultData = await _settingsService.saveSettings(
        data,
        logoPath: logoPath,
        qrisImagePath: qrisImagePath,
      );
      if (resultData != null) {
        settings.value = resultData;
        return true;
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
