import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/pos_cart_controller.dart';
import 'package:mobile_flutter/controllers/payment_controller.dart';
import 'package:mobile_flutter/controllers/kasir_controller.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/controllers/order_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:mobile_flutter/utils/pdf_receipt_generator.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';

class PembayaranPage extends StatelessWidget {
  PembayaranPage({super.key});

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final PosCartController cartController = Get.find<PosCartController>();
    final PaymentController paymentController = Get.find<PaymentController>();
    final KasirController kasirController = Get.find<KasirController>();

    return Obx(() {
      if (paymentController.isSuccess.value) {
        return _buildSuccessState(context, cartController, paymentController, kasirController);
      }
      return _buildPaymentLayout(context, cartController, paymentController);
    });
  }

  Widget _buildPaymentLayout(BuildContext context, PosCartController cartController, PaymentController paymentController) {
    return Container(
      color: const Color(0xFFF8FAFC), // very light gray background like image
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), // constrain width like a mobile view
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text("Pembayaran", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.slate900)),
                const SizedBox(height: 4),
                Text("Pilih metode pembayaran.", style: GoogleFonts.outfit(fontSize: 14, color: AppColors.slate500)),
                const SizedBox(height: 24),

                // Order Accordion
                _buildOrderAccordion(cartController),
                const SizedBox(height: 24),

                // Payment Toggles
                Row(
                  children: [
                    _paymentMethodCard(paymentController, 0, "Tunai", LucideIcons.wallet),
                    const SizedBox(width: 16),
                    _paymentMethodCard(paymentController, 1, "QRIS", LucideIcons.qrCode),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Content depending on Tab
                Obx(() {
                  bool isQRIS = paymentController.selectedTab.value == 1;
                  return Column(
                    children: [
                      if (isQRIS) ...[
                        _buildQRSection(),
                        const SizedBox(height: 24),
                      ],
                      // Form section
                      _buildPaymentForm(cartController, paymentController, isQRIS),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderAccordion(PosCartController cartController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Obx(() {
        int totalItems = cartController.cartItems.fold(0, (sum, item) => sum + item.qty.value);
        return ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none), // removes default border when expanded
          title: Text("Pesanan Kamu ($totalItems item)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text("${currencyFormatter.format(cartController.total)} total", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: cartController.cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.qty.value}x", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                  Text(currencyFormatter.format(item.price * item.qty.value), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.slate500)),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _paymentMethodCard(PaymentController paymentController, int index, String label, IconData icon) {
    return Obx(() {
      bool isActive = paymentController.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            paymentController.selectedTab.value = index;
            // if QRIS, set quick amount to total so submit is allowed immediately
            if (index == 1) {
              paymentController.setQuickAmount(Get.find<PosCartController>().total);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.slate200,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: isActive ? AppColors.primary : AppColors.slate400, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: isActive ? AppColors.primary : AppColors.slate500,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate300, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.network(
            "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=MENUKU_POS_PAYMENT", 
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(PosCartController cartController, PaymentController paymentController, bool isQRIS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Pembayaran Box
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Pembayaran", style: GoogleFonts.outfit(color: AppColors.slate500, fontWeight: FontWeight.bold)),
            Text(currencyFormatter.format(cartController.total), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.slate900)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Input Uang Diterima & Kembalian (Always visible in the mockup, though logically strange for QRIS)
        Obx(() {
          double received = paymentController.uangDiterima.value;
          double change = received - cartController.total;
          bool isNegative = change < 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Uang Diterima", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.slate300)),
                ),
                child: Text(
                  currencyFormatter.format(received),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.slate900),
                ),
              ),
              const SizedBox(height: 16),
              
              // Kembalian Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isNegative ? AppColors.slate100 : const Color(0xFF10B981), // Green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kembalian", style: GoogleFonts.outfit(color: isNegative ? AppColors.slate400 : Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      isNegative ? "Rp 0" : currencyFormatter.format(change),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: isNegative ? AppColors.slate500 : Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 24),
        
        // Numpad Section
        _buildNumpad(paymentController, isQRIS),
        const SizedBox(height: 16),
        
        // Quick amount buttons (only show on Tunai)
        if (!isQRIS)
          Row(
            children: [
              _quickAmountBtn(paymentController, 50000, "50.000"),
              const SizedBox(width: 8),
              _quickAmountBtn(paymentController, 100000, "100.000"),
              const SizedBox(width: 8),
              _quickAmountBtn(paymentController, cartController.total, "Uang Pas"),
            ],
          ),
        
        const SizedBox(height: 24),
        
        // Action Button
        _buildActionButtons(cartController, paymentController, isQRIS),
      ],
    );
  }

  Widget _buildNumpad(PaymentController paymentController, bool isQRIS) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF24252E), // Dark background matching image
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _numpadBtn(paymentController, "1", isQRIS), _numpadBtn(paymentController, "2", isQRIS), _numpadBtn(paymentController, "3", isQRIS),
          _numpadBtn(paymentController, "4", isQRIS), _numpadBtn(paymentController, "5", isQRIS), _numpadBtn(paymentController, "6", isQRIS),
          _numpadBtn(paymentController, "7", isQRIS), _numpadBtn(paymentController, "8", isQRIS), _numpadBtn(paymentController, "9", isQRIS),
          _numpadBtn(paymentController, "000", isQRIS), _numpadBtn(paymentController, "0", isQRIS), _numpadBtn(paymentController, "backspace", isQRIS, icon: LucideIcons.delete),
        ],
      ),
    );
  }

  Widget _quickAmountBtn(PaymentController paymentController, double amount, String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => paymentController.setQuickAmount(amount),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slate700,
          side: const BorderSide(color: AppColors.slate300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _numpadBtn(PaymentController paymentController, String val, bool isQRIS, {IconData? icon}) {
    return GestureDetector(
      onTap: isQRIS ? null : () => paymentController.appendNumpad(val),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2F38), // Slightly lighter dark for keys
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B3C45)), // subtle border
        ),
        child: Center(
          child: icon != null 
            ? Icon(icon, color: Colors.white, size: 20)
            : Text(
                val, 
                style: GoogleFonts.outfit(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                )
              ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(PosCartController cartController, PaymentController paymentController, bool isQRIS) {
    final orderController = Get.find<OrderController>();
    final tableController = Get.find<TableController>();
    
    return Obx(() {
      bool isAmountEnough = paymentController.uangDiterima.value >= cartController.total;
      bool canConfirm = isQRIS || isAmountEnough;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canConfirm
              ? () async {
                  String? tableName;
                  if (cartController.selectedTable.value != 0) {
                    final table = tableController.tables.firstWhereOrNull((t) => t.id == cartController.selectedTable.value);
                    tableName = table?.name ?? "Meja ${table?.number}";
                  }

                  final success = await orderController.createPosOrder(
                    items: cartController.cartItems,
                    paymentMethod: paymentController.selectedTab.value == 0 ? 'tunai' : 'qris',
                    tableName: tableName,
                    isTakeAway: cartController.selectedTable.value == 0,
                  );

                  if (success != null) {
                    paymentController.processPayment(success as Map<String, dynamic>);
                  } else {
                    Get.snackbar(
                      "Error", 
                      "Gagal menyimpan pesanan", 
                      backgroundColor: Colors.red, 
                      colorText: Colors.white,
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.slate300,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            "Konfirmasi Pembayaran",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  // SUCCESS STATE (Image 4)
  Widget _buildSuccessState(BuildContext context, PosCartController cartController, PaymentController paymentController, KasirController kasirController) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Success Icon & Text
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text("Pembayaran Berhasil!", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.slate900)),
              Text("Terima kasih, pesananmu sedang diproses.", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 14)),
              const SizedBox(height: 32),
              
              // Receipt Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    // Receipt Header
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text("Rayyanza City", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
                          Text("Jl. Sudirman No. 12, Jakarta", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.slate500)),
                          const SizedBox(height: 16),
                          const Divider(),
                        ],
                      ),
                    ),
                    
                    // Receipt Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ...cartController.cartItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("${item.qty}x ${item.name}", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold))),
                                Text(currencyFormatter.format(item.price * item.qty.value), style: GoogleFonts.outfit(fontSize: 13)),
                              ],
                            ),
                          )),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Subtotal", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 13)),
                              Text(currencyFormatter.format(cartController.subtotal), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Pajak (10%)", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 13)),
                              Text(currencyFormatter.format(cartController.tax), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("TOTAL", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                                Text(currencyFormatter.format(cartController.total), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authController = Get.find<AuthController>();
                        final order = paymentController.lastOrderData;
                        
                        final pdfData = await PdfReceiptGenerator.generateReceipt(
                          orderId: "#TRX${order['id'].toString().padLeft(3, '0')}",
                          cashierName: authController.user['name'] ?? 'Admin/Kasir',
                          date: DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(order['created_at'] ?? DateTime.now().toIso8601String())),
                          customerName: order['name'] ?? 'Pelanggan',
                          orderType: order['address'] ?? 'Dine In',
                          items: order['items'] as List? ?? [],
                          subtotal: cartController.subtotal,
                          tax: cartController.tax,
                          discount: double.tryParse(order['discount']?.toString() ?? '0') ?? 0,
                          total: cartController.total,
                        );
                        
                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdfData,
                          name: 'Struk_TRX${order['id']}',
                        );
                      },
                      icon: const Icon(LucideIcons.printer, size: 18),
                      label: Text("Print Struk", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B), // Slate 800
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.messageCircle, size: 18),
                      label: Text("Kirim WhatsApp", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E293B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cartController.clearCart();
                    paymentController.resetPayment();
                    kasirController.changeIndex(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Kembali ke Menu Awal", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
