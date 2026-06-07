import 'dart:convert';
import 'package:mobile_flutter/services/api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<dynamic> getAllOrders() async {
    final response = await _apiService.get('/all-orders');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _apiService.get('/dashboard');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    final response = await _apiService.post('/orders/$orderId/status', {
      'status': status,
    });
    return response.statusCode == 200;
  }

  Future<bool> confirmPayment(int orderId) async {
    final response = await _apiService.post('/orders/$orderId/status', {
      'payment_status': 'paid',
    });
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> createPosOrder({
    required List<dynamic> items,
    required String paymentMethod,
    String? tableName,
    bool isTakeAway = false,
  }) async {
    final response = await _apiService.post('/checkout', {
      'payment_method': paymentMethod,
      'name': isTakeAway ? 'Take Away' : (tableName ?? 'Dine In'),
      'address': isTakeAway ? 'Take Away' : (tableName ?? 'Dine In'),
      'phone': '-',
      'email': 'pos@menuku.com',
      'items': items.map((item) => {
        'product_id': item.id,
        'quantity': item.qty.value,
      }).toList(),
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
