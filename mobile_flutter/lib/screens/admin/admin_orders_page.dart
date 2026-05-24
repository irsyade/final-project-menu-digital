import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/order_controller.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final OrderController orderController = Get.find<OrderController>();
  final selectedTrx = Rxn<dynamic>();
  String _filterStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Row(
          children: [
            // Left Column: List
            Expanded(
              flex: 65,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildMonitoringBanner(),
                    _buildFilters(),
                    _buildSearchField(),
                    Expanded(child: _buildTransactionList(isMobile: isMobile)),
                  ],
                ),
              ),
            ),
            // Divider
            if (!isMobile) Container(width: 1, color: AppColors.slate100),
            // Right Column: Details (only if not mobile)
            if (!isMobile)
              Expanded(
                flex: 35,
                child: Obx(() => _buildDetailPanel(context)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'Pesanan Masuk',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900),
      ),
    );
  }

  Widget _buildMonitoringBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.eye, color: Color(0xFF3B82F6), size: 16),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mode monitoring — pesanan dikelola oleh kasir',
              style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final statuses = ['Semua', 'Baru', 'Diproses', 'Selesai'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: statuses.map((status) {
          bool isActive = _filterStatus == status;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = status),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.slate200),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : AppColors.slate400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nomor pesanan atau meja...',
          hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.slate300),
          filled: true,
          fillColor: AppColors.slate50,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList({bool isMobile = false}) {
    return Obx(() {
      if (orderController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      List<dynamic> orders = orderController.allOrders;
      
      // Basic filtering
      if (_filterStatus != 'Semua') {
        String mappedStatus = _filterStatus == 'Baru' ? 'pending' : (_filterStatus == 'Diproses' ? 'processing' : 'completed');
        orders = orders.where((o) => o['status'].toString().toLowerCase() == mappedStatus).toList();
      }

      if (orders.isEmpty) {
        return const Center(child: Text('Tidak ada pesanan', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold)));
      }
      
      return ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final trx = orders[index];
          return GestureDetector(
            onTap: () {
              selectedTrx.value = trx;
              if (isMobile) {
                _showMobileDetail(context, trx);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate100),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("#ORD-${trx['id'].toString().padLeft(3, '0')}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.slate900)),
                            Text(
                              DateFormat('HH:mm').format(DateTime.parse(trx['created_at'])), 
                              style: const TextStyle(color: AppColors.slate300, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (trx['name'] ?? 'Meja -').toString(), 
                              style: const TextStyle(color: AppColors.slate500, fontSize: 13, fontWeight: FontWeight.bold)
                            ),
                            Text(
                              "${(trx['items'] as List?)?.length ?? 0} item", 
                              style: const TextStyle(color: AppColors.slate400, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(trx['total_price'].toString()) ?? 0), 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary)
                            ),
                            _statusBadge(trx['status']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.amber; label = 'Baru'; break;
      case 'processing': color = Colors.blue; label = 'Diproses'; break;
      case 'completed': color = Colors.green; label = 'Selesai'; break;
      case 'cancelled': color = Colors.red; label = 'Dibatalkan'; break;
      default: color = Colors.grey; label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  void _showMobileDetail(BuildContext context, dynamic trx) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Obx(() => _buildDetailPanel(context)),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    if (selectedTrx.value == null) {
      return const Center(child: Text("Pilih transaksi untuk melihat detail", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
    }

    final trx = selectedTrx.value!;
    final List items = trx['items'] ?? [];

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#ORD-${trx['id'].toString().padLeft(3, '0')}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              Row(
                children: [
                  _statusBadge(trx['status']),
                  const SizedBox(width: 8),
                  Text(DateFormat('HH:mm').format(DateTime.parse(trx['created_at'])), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("${trx['name'] ?? 'Meja -'} • Kapasitas 2 • Regular", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 24),
          _buildMonitoringBanner(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.utensils, color: AppColors.slate300, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((item['product'] != null ? item['product']['name'] : '-') ?? '-', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          Text("x${item['quantity']}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format((double.tryParse(item['price'].toString()) ?? 0) * item['quantity']), 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 32, color: AppColors.slate50),
          _summaryRow("Subtotal", trx['subtotal'] ?? trx['total_price']),
          _summaryRow("Pajak (10%)", (double.tryParse((trx['subtotal'] ?? trx['total_price']).toString()) ?? 0) * 0.1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              Text(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(double.tryParse(trx['total_price'].toString()) ?? 0), 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primary)
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Buttons for Admin Detail Panel
          if (trx['status'].toString().toLowerCase() == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(trx['id'], 'processing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('TERIMA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(trx['id'], 'cancelled'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('TOLAK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ],
            ),
            
          if (trx['status'].toString().toLowerCase() == 'processing')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(trx['id'], 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('TANDAI SELESAI', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(trx['id'], 'cancelled'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('TOLAK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    bool success = await orderController.updateOrderStatus(id, status);
    if (success) {
      // Refresh local selection
      final updatedOrder = orderController.allOrders.firstWhere((o) => o['id'] == id, orElse: () => null);
      if (updatedOrder != null) selectedTrx.value = updatedOrder;
      
      Get.snackbar(
        'Berhasil', 
        'Status diperbarui.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  Widget _summaryRow(String label, dynamic value) {
    num val = 0;
    if (value is num) {
      val = value;
    } else if (value is String) {
      val = num.tryParse(value) ?? 0;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
          ),
        ],
      ),
    );
  }
}
