import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile_flutter/models/promo.dart';
import 'package:mobile_flutter/services/api_service.dart';

class PromoController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var promos = <Promo>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPromos();
  }

  Future<void> fetchPromos() async {
    isLoading(true);
    try {
      final response = await _apiService.get('/promos');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        promos.value = data.map((e) => Promo.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching promos: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> createPromo(Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.post('/promos', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchPromos();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal menambah promo"};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updatePromo(int id, Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.put('/promos/$id', data);
      if (response.statusCode == 200) {
        fetchPromos();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal memperbarui promo"};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deletePromo(int id) async {
    isLoading(true);
    try {
      final response = await _apiService.delete('/promos/$id');
      if (response.statusCode == 200) {
        fetchPromos();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting promo: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> togglePromoStatus(int id) async {
    try {
      final response = await _apiService.post('/promos/$id/toggle', {});
      if (response.statusCode == 200) {
        fetchPromos();
      }
    } catch (e) {
      print("Error toggling promo: $e");
    }
  }
}
