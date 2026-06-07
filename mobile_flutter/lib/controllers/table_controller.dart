import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter/models/table.dart';
import 'package:mobile_flutter/services/table_service.dart';

class TableController extends GetxController {
  final TableService _tableService = TableService();

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
      tables.value = await _tableService.getTables();
    } catch (e) {
      print("Error fetching tables: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> createTable(Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final result = await _tableService.createTable(data);
      if (result['success'] == true) {
        await fetchTables();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateTable(int id, Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final result = await _tableService.updateTable(id, data);
      if (result['success'] == true) {
        await fetchTables();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteTable(int id) async {
    isLoading(true);
    try {
      final success = await _tableService.deleteTable(id);
      if (success) {
        await fetchTables();
      }
      return success;
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

      final result = await _tableService.updateTable(id, {
        'number': table.number,
        'name': table.name ?? '',
        'type': table.type,
        'capacity': table.capacity,
        'status': table.status,
        'is_active': newIsActive,
      });

      if (result['success'] == true) {
        await fetchTables();
      } else {
        print("Toggle failed: ${result['message']}");
        Get.snackbar("Gagal", "Tidak dapat mengubah status meja",
            backgroundColor: const Color(0xFFEF4444), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      print("Error toggling table: $e");
    }
  }

  /// Update status ketersediaan meja (available, occupied, reserved)
  Future<void> updateTableStatus(int id, String newStatus) async {
    try {
      final table = tables.firstWhereOrNull((t) => t.id == id);
      if (table == null) return;

      final result = await _tableService.updateTable(id, {
        'number': table.number,
        'name': table.name ?? '',
        'type': table.type,
        'capacity': table.capacity,
        'status': newStatus,
        'is_active': table.isActive,
      });

      if (result['success'] == true) {
        await fetchTables();
      } else {
        print("Status update failed: ${result['message']}");
        Get.snackbar("Gagal", "Tidak dapat mengubah status meja",
            backgroundColor: const Color(0xFFEF4444), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      print("Error updating status table: $e");
    }
  }
}
