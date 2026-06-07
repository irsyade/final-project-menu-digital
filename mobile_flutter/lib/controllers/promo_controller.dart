import 'package:get/get.dart';
import 'package:mobile_flutter/models/promo.dart';
import 'package:mobile_flutter/services/promo_service.dart';

class PromoController extends GetxController {
  final PromoService _promoService = PromoService();

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
      promos.value = await _promoService.getPromos();
    } catch (e) {
      print("Error fetching promos: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> createPromo(Map<String, dynamic> data, {String? imagePath}) async {
    isLoading(true);
    try {
      final result = await _promoService.createPromo(data, imagePath: imagePath);
      if (result['success'] == true) {
        fetchPromos();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updatePromo(int id, Map<String, dynamic> data, {String? imagePath}) async {
    isLoading(true);
    try {
      final result = await _promoService.updatePromo(id, data, imagePath: imagePath);
      if (result['success'] == true) {
        fetchPromos();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deletePromo(int id) async {
    isLoading(true);
    try {
      final success = await _promoService.deletePromo(id);
      if (success) {
        fetchPromos();
      }
      return success;
    } catch (e) {
      print("Error deleting promo: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> togglePromoStatus(int id) async {
    try {
      final success = await _promoService.togglePromoStatus(id);
      if (success) {
        fetchPromos();
      }
    } catch (e) {
      print("Error toggling promo: $e");
    }
  }
}
