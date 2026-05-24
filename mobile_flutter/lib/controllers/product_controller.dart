import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile_flutter/models/category.dart';
import 'package:mobile_flutter/models/product.dart';
import 'package:mobile_flutter/services/api_service.dart';

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var categories = <Category>[].obs;
  var products = <Product>[].obs;
  var popularProducts = <Product>[].obs;
  var selectedCategory = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchPopularProducts();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.get('/categories');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        categories.value = data.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchProducts({int? categoryId, String? query}) async {
    isLoading(true);
    try {
      String endpoint = '/products';
      if (query != null && query.isNotEmpty) {
        endpoint += '/search?q=$query';
      } else if (categoryId != null && categoryId != 0) {
        endpoint += '?category_id=$categoryId';
      }
      
      final response = await _apiService.get(endpoint);
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          products.value = decoded.map((e) => Product.fromJson(e)).toList();
        } else {
          print("Warning: /products returned non-list data: $decoded");
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPopularProducts() async {
    try {
      final response = await _apiService.get('/products/popular');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        popularProducts.value = data.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching popular products: $e");
    }
  }

  void selectCategory(int id) {
    selectedCategory.value = id;
    fetchProducts(categoryId: id);
  }

  // === PRODUCT CRUD ===
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.post('/products', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchProducts();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal menambah produk"};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    isLoading(true);
    try {
      final response = await _apiService.put('/products/$id', data);
      if (response.statusCode == 200) {
        fetchProducts();
        return {"success": true};
      }
      final errorData = jsonDecode(response.body);
      return {"success": false, "message": errorData['message'] ?? "Gagal memperbarui produk"};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteProduct(int id) async {
    isLoading(true);
    try {
      final response = await _apiService.delete('/products/$id');
      if (response.statusCode == 200) {
        fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting product: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleProductAvailability(int id) async {
    try {
      final response = await _apiService.post('/products/$id/toggle', {});
      if (response.statusCode == 200) {
        fetchProducts();
      }
    } catch (e) {
      print("Error toggling product: $e");
    }
  }

  // === CATEGORY CRUD ===
  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/categories', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      print("Error creating category: $e");
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/categories/$id', data);
      if (response.statusCode == 200) {
        fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.delete('/categories/$id');
      if (response.statusCode == 200) {
        fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }
}
