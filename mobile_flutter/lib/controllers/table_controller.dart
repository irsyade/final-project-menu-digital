import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter/models/table.dart';
import 'package:mobile_flutter/services/api_service.dart';

class TableController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var tables = <TableModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  Future<void> fetchTables() async {
    isLoading(true);
    try {
      final response = await _apiService.get('/tables');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        tables.value = data.map((e) => TableModel.fromJson(e)).toList();
      } else {
        print("Error fetching tables: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching tables: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> createTable(Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.post('/tables', data);
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchTables();
        return {"success": true};
      }
      return {
        "success": false,
        "message": body['message'] ?? "Gagal menambah meja (${response.statusCode})"
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateTable(int id, Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.put('/tables/$id', data);
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await fetchTables();
        return {"success": true};
      }
      return {
        "success": false,
        "message": body['message'] ?? "Gagal memperbarui meja (${response.statusCode})"
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteTable(int id) async {
    isLoading(true);
    try {
      final response = await _apiService.delete('/tables/$id');
      if (response.statusCode == 200) {
        await fetchTables();
        return true;
      }
      print("Delete failed: ${response.statusCode} ${response.body}");
      return false;
    } catch (e) {
      print("Error deleting table: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Toggle aktif/nonaktif meja tanpa mengubah field lain
  Future<void> toggleTableActive(int id, bool newIsActive) async {
    try {
      final table = tables.firstWhereOrNull((t) => t.id == id);
      if (table == null) return;

      final response = await _apiService.put('/tables/$id', {
        'number': table.number,
        'name': table.name ?? '',
        'type': table.type,
        'capacity': table.capacity,
        'status': table.status,
        'is_active': newIsActive,
      });

      if (response.statusCode == 200) {
        await fetchTables();
      } else {
        print("Toggle failed: ${response.statusCode} ${response.body}");
        Get.snackbar("Gagal", "Tidak dapat mengubah status meja",
            backgroundColor: const Color(0xFFEF4444), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      print("Error toggling table: $e");
    }
  }
}
