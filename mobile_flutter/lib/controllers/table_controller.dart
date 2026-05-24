import 'dart:convert';
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchTables();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal menambah meja"};
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
      if (response.statusCode == 200) {
        fetchTables();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal memperbarui meja"};
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
        fetchTables();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting table: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleTableStatus(int id) async {
    try {
      // Assuming there's a toggle endpoint or we just use update
      final table = tables.firstWhere((t) => t.id == id);
      final response = await _apiService.put('/tables/$id', {
        ...TableModel.toJson(table), // Need toJson in TableModel
        'is_active': !table.isActive
      });
      if (response.statusCode == 200) {
        fetchTables();
      }
    } catch (e) {
      print("Error toggling table: $e");
    }
  }
}
