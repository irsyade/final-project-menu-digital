import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/order_controller.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';

class RiwayatPesananPage extends StatelessWidget {
  RiwayatPesananPage({super.key});

  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  final selectedTrx = Rxn<dynamic>();
  final currentFilter = 'Semua'.obs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Container(
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSummaryStats(),
                _buildFilters(),
                Expanded(child: _buildTransactionList(isMobile: true)),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Left Column: List (60%)
            Expanded(
              flex: 60,
              child: Container(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSummaryStats(),
                    _buildFilters(),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC), // Slight background for list area
                        child: _buildTransactionList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Container(width: 1, color: AppColors.slate200),
            // Right Column: Details (40%)
            Expanded(
              flex: 40,
              child: Obx(() => _buildDetailPanel(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        "Pesanan Masuk",
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w900,
          fontSize: 24,
          color: AppColors.slate900,
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Obx(() {
      final total = orderController.allOrders.length;
      final lunas = orderController.allOrders.where((o) => o['status'] == 'completed').length;
      final pending = orderController.allOrders.where((o) => o['status'] == 'processing' || o['status'] == 'pending').length;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _statCard("Total Transaksi", total.toString()),
            const SizedBox(width: 16),
            _statCard("Lunas", lunas.toString()),
            const SizedBox(width: 16),
            _statCard("Pending", pending.toString()),
          ],
        ),
      );
    });
  }

  Widget _statCard(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.slate900)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.outfit(color: AppColors.slate400, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ["Baru", "Semua", "Diproses", "Lunas", "Dibatalkan"];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) => _filterChip(f)).toList(),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    return Obx(() {
      bool isActive = currentFilter.value == label;
      return GestureDetector(
        onTap: () {
          currentFilter.value = label;
          selectedTrx.value = null; // reset selection when filter changes
        },
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? AppColors.primary : AppColors.slate200),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? Colors.white : AppColors.slate500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTransactionList({bool isMobile = false}) {
    return Obx(() {
      if (orderController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final String filter = currentFilter.value;
      List<dynamic> orders = orderController.allOrders.toList();
      
      // Map API statuses to our filter labels
      if (filter == 'Baru') {
        orders = orders.where((o) => o['status'] == 'pending').toList();
      } else if (filter == 'Diproses') {
        orders = orders.where((o) => o['status'] == 'processing').toList();
      } else if (filter == 'Lunas') {
        orders = orders.where((o) => o['status'] == 'completed').toList();
      } else if (filter == 'Dibatalkan') {
        orders = orders.where((o) => o['status'] == 'cancelled').toList();
      }
      
      if (orders.isEmpty) {
        return Center(
          child: Text(
            "Tidak ada pesanan", 
            style: GoogleFonts.outfit(color: AppColors.slate400, fontWeight: FontWeight.bold)
          )
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final trx = orders[index];
          return Obx(() {
            bool isSelected = selectedTrx.value?['id'] == trx['id'];
            return GestureDetector(
              onTap: () {
                selectedTrx.value = trx;
                if (isMobile) {
                  _showMobileDetail(context, trx);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#TRX${trx['id'].toString().padLeft(3, '0')}", 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.slate900)
                        ),
                        _statusBadgeWidget(trx['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(trx['created_at'])), 
                      style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${trx['address'] == 'Take Away' ? 'Take Away' : (trx['table_number'] != null ? 'Meja ${trx['table_number']}' : 'Web Order')} • ${trx['items']?.length ?? 0} item", 
                          style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(double.tryParse(trx['total_price'].toString()) ?? 0, 0), 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.slate900)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _statusBadgeWidget(String status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey.shade600;
    IconData icon = LucideIcons.circle;
    String label = "UNKNOWN";

    if (status == 'pending') { 
      bg = const Color(0xFFE0F2FE); // light blue
      text = const Color(0xFF0284C7); // blue
      icon = LucideIcons.sun; // Using sun/star like image
      label = "Baru";
    } else if (status == 'processing') { 
      bg = const Color(0xFFFFEDD5); // light orange
      text = const Color(0xFFEA580C); // orange
      icon = LucideIcons.clock;
      label = "Diproses";
    } else if (status == 'completed') { 
      bg = const Color(0xFFDCFCE7); // light green
      text = const Color(0xFF16A34A); // green
      icon = LucideIcons.checkCircle2;
      label = "Lunas";
    } else if (status == 'cancelled') { 
      bg = const Color(0xFFFEE2E2); // light red
      text = const Color(0xFFDC2626); // red
      icon = LucideIcons.xCircle;
      label = "Dibatalkan";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: text, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
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
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileText, size: 48, color: AppColors.slate200),
              const SizedBox(height: 16),
              Text("Pilih pesanan untuk melihat detail", style: GoogleFonts.outfit(color: AppColors.slate400, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final trx = selectedTrx.value!;
    final double total = double.tryParse(trx['total_price'].toString()) ?? 0;
    final double subtotal = total / 1.1;
    final double tax = total - subtotal;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Detail Transaksi", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.slate900)),
          const SizedBox(height: 4),
          Text("#TRX${trx['id'].toString().padLeft(3, '0')}", style: GoogleFonts.outfit(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 13)),
          
          const SizedBox(height: 24),
          Text("Status", style: GoogleFonts.outfit(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _statusBadgeWidget(trx['status'])
          ),
          
          const SizedBox(height: 32),
          _detailRow("Waktu", DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(trx['created_at']))),
          _detailRow("Meja", trx['address'] ?? 'Take Away'),
          _detailRow("Kasir", authController.user['name'] ?? 'Rina'), // fallback to Rina as in mockup if null
          _detailRow("Pembayaran", (trx['payment_method'] ?? 'tunai').toString().capitalizeFirst!),
          
          const SizedBox(height: 32),
          Text("Item Pesanan", style: GoogleFonts.outfit(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.separated(
              itemCount: (trx['items'] as List).length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = trx['items'][index];
                final price = double.tryParse(item['price'].toString()) ?? 0;
                final qty = int.tryParse(item['quantity'].toString()) ?? 0;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${qty}x ${item['product']?['name'] ?? item['product_name'] ?? 'Produk Tidak Ditemukan'}", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.slate900)),
                          const SizedBox(height: 2),
                          Text("@ ${CurrencyFormat.convertToIdr(price, 0)}", style: GoogleFonts.outfit(color: AppColors.slate400, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(CurrencyFormat.convertToIdr(price * qty, 0), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900)),
                  ],
                );
              },
            ),
          ),
          
          const Divider(height: 32),
          
          _summaryRow("Subtotal", CurrencyFormat.convertToIdr(subtotal, 0)),
          _summaryRow("Pajak (10%)", CurrencyFormat.convertToIdr(tax, 0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.slate900)),
              Text(CurrencyFormat.convertToIdr(total, 0), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons based on status
          if (trx['status'] == 'pending') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  bool success = await orderController.updateOrderStatus(trx['id'], 'processing');
                  if (success) {
                    trx['status'] = 'processing';
                    selectedTrx.refresh();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: Text("Terima Pesanan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  bool success = await orderController.updateOrderStatus(trx['id'], 'cancelled');
                  if (success) {
                    trx['status'] = 'cancelled';
                    selectedTrx.refresh();
                  }
                },
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFEF4444), side: const BorderSide(color: Color(0xFFEF4444)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("Tolak Pesanan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (trx['status'] == 'processing') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  bool success = await orderController.updateOrderStatus(trx['id'], 'completed');
                  if (success) {
                    trx['status'] = 'completed';
                    selectedTrx.refresh();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: Text("Selesaikan Pesanan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (trx['status'] == 'completed') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showReceiptDialog(context, trx),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: Text("Cetak Struk", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppColors.slate400, fontSize: 13)),
          Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 13)),
          Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900)),
        ],
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, dynamic trx) {
    final double total = double.tryParse(trx['total_price'].toString()) ?? 0;
    final double subtotal = total / 1.1;
    final double tax = total - subtotal;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.slate900,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("PRATINJAU STRUK", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, color: Colors.white, size: 16)),
                  ],
                ),
              ),
              
              // Receipt Content (Thermal Style)
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    Text("MenuKu Resto", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20)),
                    Text("Jl. Digital Menu No. 123", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.slate500)),
                    const Divider(height: 32, thickness: 1, color: AppColors.slate300),
                    
                    _receiptRow("No. Transaksi", "#TRX${trx['id'].toString().padLeft(3, '0')}"),
                    _receiptRow("Kasir", authController.user['name'] ?? 'Admin/Kasir'),
                    _receiptRow("Waktu", DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(trx['created_at']))),
                    _receiptRow("Tipe", trx['address'] ?? 'Dine In'),
                    
                    const Divider(height: 32, thickness: 1, color: AppColors.slate300),
                    
                    // Items
                    ...(trx['items'] as List).map((item) {
                      final p = double.tryParse(item['price'].toString()) ?? 0;
                      final q = int.tryParse(item['quantity'].toString()) ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("${q}x ${item['product']?['name'] ?? item['product_name'] ?? 'Produk Tidak Ditemukan'}", style: GoogleFonts.outfit(fontSize: 13))),
                            Text(CurrencyFormat.convertToIdr(p * q, 0), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const Divider(height: 32, thickness: 1, color: AppColors.slate300),
                    
                    _receiptRow("Subtotal", CurrencyFormat.convertToIdr(subtotal, 0)),
                    _receiptRow("Pajak (10%)", CurrencyFormat.convertToIdr(tax, 0)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TOTAL", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text(CurrencyFormat.convertToIdr(total, 0), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Text("TERIMA KASIH", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 4, color: AppColors.slate400, fontSize: 12)),
                    Text("Silakan berkunjung kembali!", style: GoogleFonts.outfit(fontSize: 10, color: AppColors.slate400)),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.download),
                    label: Text("SIMPAN GAMBAR", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.slate900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.slate500)),
          Text(val, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
