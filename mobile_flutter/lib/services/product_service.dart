import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/models/category.dart';
import 'package:mobile_flutter/models/product.dart';
import 'package:mobile_flutter/services/api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // === PRODUCTS ===
  Future<List<Product>> getProducts({int? categoryId, String? query}) async {
    String endpoint = '/products';
    if (query != null && query.isNotEmpty) {
      endpoint += '/search?q=$query';
    } else if (categoryId != null && categoryId != 0) {
      endpoint += '?category_id=$categoryId';
    }
    
    final response = await _apiService.get(endpoint);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Product.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<List<Product>> getPopularProducts() async {
    final response = await _apiService.get('/products/popular');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data, {String? imagePath}) async {
    // Normalize data — convert bool to int, ensure types are correct
    final normalized = _normalizeProductData(data);

    if (imagePath != null && imagePath.isNotEmpty) {
      final fields = normalized.map((key, value) => MapEntry(key, value.toString()));
      final streamedResponse = await _apiService.postMultipart(
        '/products',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      return {"success": false, "message": _parseError(response.body, "Gagal menambah produk")};
    } else {
      final response = await _apiService.post('/products', normalized);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      return {"success": false, "message": _parseError(response.body, "Gagal menambah produk")};
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data, {String? imagePath}) async {
    final normalized = _normalizeProductData(data);

    if (imagePath != null && imagePath.isNotEmpty) {
      final fields = normalized.map((key, value) => MapEntry(key, value.toString()));
      fields['_method'] = 'PUT'; // Laravel method spoofing
      final streamedResponse = await _apiService.postMultipart(
        '/products/$id',
        fields,
        filePath: imagePath,
        fileField: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('updateProduct multipart [${response.statusCode}]: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }
      return {"success": false, "message": _parseError(response.body, "Gagal memperbarui produk (${response.statusCode})")};
    } else {
      final response = await _apiService.put('/products/$id', normalized);
      debugPrint('updateProduct put [${response.statusCode}]: ${response.body}');
      if (response.statusCode == 200) {
        return {"success": true};
      }
      return {"success": false, "message": _parseError(response.body, "Gagal memperbarui produk (${response.statusCode})")};
    }
  }

  /// Normalize product data — convert bool→int, ensure numbers stay as numbers
  Map<String, dynamic> _normalizeProductData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      if (value == null) return;
      if (value is bool) {
        result[key] = value ? 1 : 0;
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Parse Laravel error response — extract validation errors or generic message
  String _parseError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        // Laravel validation errors: {"message":"...", "errors":{"field":["msg"]}}
        if (decoded['errors'] is Map) {
          final errors = decoded['errors'] as Map;
          final firstKey = errors.keys.first;
          final messages = errors[firstKey];
          if (messages is List && messages.isNotEmpty) {
            return '$firstKey: ${messages.first}';
          }
        }
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}
    return fallback;
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final response = await _apiService.delete('/products/$id');
    debugPrint('deleteProduct [${response.statusCode}]: ${response.body}');
    // Accept 200 or 204 (No Content) as success
    if (response.statusCode == 200 || response.statusCode == 204) {
      return {"success": true};
    }
    return {"success": false, "message": _parseError(response.body, "Gagal menghapus produk (${response.statusCode})")};
  }

  Future<bool> toggleProductAvailability(int id) async {
    final response = await _apiService.post('/products/$id/toggle', {});
    return response.statusCode == 200;
  }

  // === CATEGORIES ===
  Future<List<Category>> getCategories() async {
    final response = await _apiService.get('/categories');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    final response = await _apiService.post('/categories', data);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/categories/$id', data);
    return response.statusCode == 200;
  }

  Future<bool> deleteCategory(int id) async {
    final response = await _apiService.delete('/categories/$id');
    return response.statusCode == 200;
  }
}
