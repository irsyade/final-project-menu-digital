import 'dart:convert';
import 'package:mobile_flutter/models/table.dart';
import 'package:mobile_flutter/services/api_service.dart';

class TableService {
  final ApiService _apiService = ApiService();

  Future<List<TableModel>> getTables() async {
    final response = await _apiService.get('/tables');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TableModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      // Silently ignore if unauthenticated (e.g., on app start)
      return [];
    } else {
      print("Error fetching tables: ${response.statusCode} ${response.body}");
      return [];
    }
  }

  Future<Map<String, dynamic>> createTable(Map<String, dynamic> data) async {
    final response = await _apiService.post('/tables', data);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    }
    return {
      "success": false,
      "message": body['message'] ?? "Gagal menambah meja (${response.statusCode})"
    };
  }

  Future<Map<String, dynamic>> updateTable(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/tables/$id', data);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {"success": true};
    }
    return {
      "success": false,
      "message": body['message'] ?? "Gagal memperbarui meja (${response.statusCode})"
    };
  }

  Future<bool> deleteTable(int id) async {
    final response = await _apiService.delete('/tables/$id');
    if (response.statusCode == 200) {
      return true;
    }
    print("Delete failed: ${response.statusCode} ${response.body}");
    return false;
  }
}
