import 'dart:async';
import 'package:get/get.dart';
import 'package:mobile_flutter/models/category.dart';
import 'package:mobile_flutter/models/product.dart';
import 'package:mobile_flutter/services/product_service.dart';
import 'package:mobile_flutter/utils/debounce.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  var isLoading = false.obs;
  var isSearching = false.obs; // separate flag so grid can show search shimmer
  var categories = <Category>[].obs;
  var products = <Product>[].obs;
  var popularProducts = <Product>[].obs;
  var selectedCategory = 0.obs;

  // Debounce for search — 400ms delay
  final _searchDebounce = Debounce(const Duration(milliseconds: 400));

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchPopularProducts();
    fetchProducts();
  }

  @override
  void onClose() {
    _searchDebounce.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      categories.value = await _productService.getCategories();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchProducts({int? categoryId, String? query}) async {
    isLoading(true);
    try {
      products.value = await _productService.getProducts(categoryId: categoryId, query: query);
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Debounced search — call this from TextField onChanged.
  /// Shows [isSearching] immediately so the UI can react,
  /// then waits 400ms before hitting the API.
  void searchProductsDebounced(String query) {
    isSearching(true);
    _searchDebounce.run(() async {
      await fetchProducts(
        categoryId: selectedCategory.value == 0 ? null : selectedCategory.value,
        query: query.trim().isEmpty ? null : query.trim(),
      );
      isSearching(false);
    });
  }

  Future<void> fetchPopularProducts() async {
    try {
      popularProducts.value = await _productService.getPopularProducts();
    } catch (e) {
      print("Error fetching popular products: $e");
    }
  }

  void selectCategory(int id) {
    selectedCategory.value = id;
    fetchProducts(categoryId: id);
  }

  // === PRODUCT CRUD ===
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data, {String? imagePath}) async {
    isLoading(true);
    try {
      final result = await _productService.createProduct(data, imagePath: imagePath);
      if (result['success'] == true) {
        fetchProducts();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data, {String? imagePath}) async {
    isLoading(true);
    try {
      final result = await _productService.updateProduct(id, data, imagePath: imagePath);
      if (result['success'] == true) {
        fetchProducts();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    isLoading(true);
    try {
      final result = await _productService.deleteProduct(id);
      if (result['success'] == true) {
        fetchProducts();
      }
      return result;
    } catch (e) {
      print("Error deleting product: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleProductAvailability(int id) async {
    // Optimistic UI Update: Find product in local list and toggle isAvailable
    final index = products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final originalProduct = products[index];
    final updatedProduct = Product(
      id: originalProduct.id,
      categoryId: originalProduct.categoryId,
      name: originalProduct.name,
      description: originalProduct.description,
      price: originalProduct.price,
      image: originalProduct.image,
      isPopular: originalProduct.isPopular,
      isAvailable: !originalProduct.isAvailable,
      categoryName: originalProduct.categoryName,
      tags: originalProduct.tags,
    );

    // Apply change immediately
    products[index] = updatedProduct;
    products.refresh();

    try {
      final success = await _productService.toggleProductAvailability(id);
      if (!success) {
        // Revert if API failed
        products[index] = originalProduct;
        products.refresh();
      } else {
        // Sync with database asynchronously
        fetchProducts();
      }
    } catch (e) {
      print("Error toggling product: $e");
      // Revert if exception occurred
      products[index] = originalProduct;
      products.refresh();
    }
  }

  // === CATEGORY CRUD ===
  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final success = await _productService.createCategory(data);
      if (success) fetchCategories();
      return success;
    } catch (e) {
      print("Error creating category: $e");
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final success = await _productService.updateCategory(id, data);
      if (success) fetchCategories();
      return success;
    } catch (e) {
      print("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final success = await _productService.deleteCategory(id);
      if (success) fetchCategories();
      return success;
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }
}
