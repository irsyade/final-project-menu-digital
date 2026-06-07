import 'dart:async';
import 'package:get/get.dart';
import 'package:mobile_flutter/services/order_service.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();
  
  var isLoading = false.obs;
  var allOrders = <dynamic>[].obs;
  var dashboardData = <String, dynamic>{}.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
    fetchDashboardData();
    startPolling();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAllOrders(showLoading: false);
      fetchDashboardData(showLoading: false);
    });
  }

  Future<void> fetchAllOrders({bool showLoading = true}) async {
    if (showLoading) isLoading(true);
    try {
      final data = await _orderService.getAllOrders();
      // Only update if data has changed to prevent unnecessary rebuilds
      if (allOrders.toString() != data.toString()) {
        allOrders.value = data;
      }
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
         // Silently ignore if unauthenticated
      } else {
        print("Error fetching all orders: $e");
      }
    } finally {
      if (showLoading) isLoading(false);
    }
  }

  Future<void> fetchDashboardData({bool showLoading = true}) async {
    if (showLoading) isLoading(true);
    try {
      final data = await _orderService.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
         // Silently ignore if unauthenticated
      } else {
        print("Error fetching dashboard data: $e");
      }
    } finally {
      if (showLoading) isLoading(false);
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      if (success) {
        fetchAllOrders(showLoading: false); // Refresh list immediately
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating status: $e");
      return false;
    }
  }

  Future<bool> confirmPayment(int orderId) async {
    try {
      final success = await _orderService.confirmPayment(orderId);
      if (success) {
        fetchAllOrders(showLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      print("Error confirming payment: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> createPosOrder({
    required List<dynamic> items,
    required String paymentMethod,
    String? tableName,
    bool isTakeAway = false,
  }) async {
    isLoading(true);
    try {
      final data = await _orderService.createPosOrder(
        items: items,
        paymentMethod: paymentMethod,
        tableName: tableName,
        isTakeAway: isTakeAway
      );

      if (data != null) {
        fetchAllOrders(showLoading: false);
        fetchDashboardData(showLoading: false);
        return data;
      }
      return null;
    } catch (e) {
      print("Error creating POS order: $e");
      return null;
    } finally {
      isLoading(false);
    }
  }

  // === REKAP HELPERS ===
  List get todayOrders {
    final now = DateTime.now();
    return allOrders.where((o) {
      final orderDate = DateTime.parse(o['created_at']);
      return orderDate.year == now.year && 
             orderDate.month == now.month && 
             orderDate.day == now.day && 
             o['status'] == 'completed';
    }).toList();
  }

  double get todayRevenue {
    return todayOrders.fold(0.0, (sum, o) => sum + (double.tryParse(o['total_price'].toString()) ?? 0));
  }

  List<Map<String, dynamic>> get topSellingProducts {
    Map<String, int> productSales = {};
    for (var order in todayOrders) {
      for (var item in order['items']) {
        String name = item['product']['name'];
        int qty = int.tryParse(item['quantity'].toString()) ?? 0;
        productSales[name] = (productSales[name] ?? 0) + qty;
      }
    }
    
    var sortedEntries = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.take(3).map((e) => {'name': e.key, 'qty': e.value}).toList();
  }
}
