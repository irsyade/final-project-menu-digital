import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/models/promo.dart';
import 'package:mobile_flutter/services/api_service.dart';

class PromoService {
  final ApiService _apiService = ApiService();

  Future<List<Promo>> getPromos() async {
    final response = await _apiService.get('/promos');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Promo.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createPromo(Map<String, dynamic> data, {String? imagePath}) async {
    // Normalize boolean fields to int (1/0) so Laravel validates correctly
    // regardless of whether it's JSON body or multipart form data
    final normalized = _normalizePromoData(data);

    if (imagePath != null && imagePath.isNotEmpty) {
      final fields = normalized.map((key, value) => MapEntry(key, value.toString()));
      final streamedResponse = await _apiService.postMultipart(
        '/promos',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      try {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": _parseError(errorData)};
      } catch (_) {
        return {"success": false, "message": "Gagal menambah promo (${response.statusCode})"};
      }
    } else {
      final response = await _apiService.post('/promos', normalized);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      try {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": _parseError(errorData)};
      } catch (_) {
        return {"success": false, "message": "Gagal menambah promo (${response.statusCode})"};
      }
    }
  }

  Future<Map<String, dynamic>> updatePromo(int id, Map<String, dynamic> data, {String? imagePath}) async {
    final normalized = _normalizePromoData(data);

    if (imagePath != null && imagePath.isNotEmpty) {
      final fields = normalized.map((key, value) => MapEntry(key, value.toString()));
      fields['_method'] = 'PUT';
      final streamedResponse = await _apiService.postMultipart(
        '/promos/$id',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      try {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": _parseError(errorData)};
      } catch (_) {
        return {"success": false, "message": "Gagal memperbarui promo (${response.statusCode})"};
      }
    } else {
      final response = await _apiService.put('/promos/$id', normalized);
      if (response.statusCode == 200) {
        return {"success": true};
      }
      try {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": _parseError(errorData)};
      } catch (_) {
        return {"success": false, "message": "Gagal memperbarui promo (${response.statusCode})"};
      }
    }
  }

  /// Convert bool → int and ensure numeric fields are numbers, not strings.
  /// This ensures Laravel validation works for both JSON and multipart.
  Map<String, dynamic> _normalizePromoData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key;
      final val = entry.value;

      if (val == null) continue; // skip null fields — let Laravel use defaults

      if (val is bool) {
        result[key] = val ? 1 : 0; // PHP accepts 1/0 as boolean in validation
      } else if (val is double && (key == 'value' || key == 'min_purchase')) {
        result[key] = val; // keep numeric
      } else {
        result[key] = val;
      }
    }
    return result;
  }

  /// Extract the most useful error message from Laravel validation response.
  String _parseError(dynamic errorData) {
    if (errorData is Map) {
      // Laravel validation errors: {"errors": {"code": ["already taken"]}}
      if (errorData.containsKey('errors') && errorData['errors'] is Map) {
        final errors = errorData['errors'] as Map;
        final firstField = errors.keys.first;
        final messages = errors[firstField];
        if (messages is List && messages.isNotEmpty) {
          return '$firstField: ${messages.first}';
        }
      }
      // Simple message
      if (errorData.containsKey('message')) {
        return errorData['message'].toString();
      }
    }
    return 'Terjadi kesalahan';
  }

  Future<bool> deletePromo(int id) async {
    final response = await _apiService.delete('/promos/$id');
    return response.statusCode == 200;
  }

  Future<bool> togglePromoStatus(int id) async {
    final response = await _apiService.post('/promos/$id/toggle', {});
    return response.statusCode == 200;
  }
}
