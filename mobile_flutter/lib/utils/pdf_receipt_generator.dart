import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_flutter/constants.dart';

class PdfReceiptGenerator {
  /// Fetch store name and address from admin settings API
  static Future<Map<String, String>> _fetchStoreInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/settings'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both response formats: {success: true, data: {...}} and direct {...}
        final settings = data['success'] == true ? data['data'] : data;
        return {
          'site_name': settings['site_name'] ?? 'MenuKu Resto',
          'address': settings['address'] ?? 'Jl. Digital Menu No. 123',
          'phone': settings['phone'] ?? '',
        };
      }
    } catch (_) {}
    return {'site_name': 'MenuKu Resto', 'address': 'Jl. Digital Menu No. 123', 'phone': ''};
  }

  static Future<Uint8List> generateReceipt({
    required String orderId,
    required String cashierName,
    required String date,
    required String customerName,
    required String orderType,
    required List<dynamic> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
  }) async {
    // Fetch store info from backend settings
    final storeInfo = await _fetchStoreInfo();
    final storeName = storeInfo['site_name']!;
    final storeAddress = storeInfo['address']!;
    final storePhone = storeInfo['phone']!;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header - Store name & address from settings
              pw.Text(storeName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 2),
              pw.Text(storeAddress, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
              if (storePhone.isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Text(storePhone, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
              ],
              pw.SizedBox(height: 8),
              _separator(),
              pw.SizedBox(height: 8),

              // Meta
              _rowText("No. Transaksi", orderId),
              _rowText("Kasir", cashierName),
              _rowText("Waktu", date),
              _rowText("Pelanggan", customerName),
              _rowText("Tipe", orderType),

              pw.SizedBox(height: 8),
              _separator(),
              pw.SizedBox(height: 8),

              // Items
              ...items.map((item) {
                final qty = int.tryParse(item['quantity'].toString()) ?? 0;
                final price = double.tryParse(item['price'].toString()) ?? 0;
                final name = item['product']?['name'] ?? item['product_name'] ?? item['name'] ?? 'Produk';
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text("${qty}x $name", style: const pw.TextStyle(fontSize: 10))),
                      pw.Text(CurrencyFormat.convertToIdr(price * qty, 0), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 8),
              _separator(),
              pw.SizedBox(height: 8),

              // Totals
              _rowText("Subtotal", CurrencyFormat.convertToIdr(subtotal, 0)),
              if (discount > 0)
                _rowText("Diskon", "-${CurrencyFormat.convertToIdr(discount, 0)}"),
              _rowText("Pajak (10%)", CurrencyFormat.convertToIdr(tax, 0)),

              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text(CurrencyFormat.convertToIdr(total, 0), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Text("TERIMA KASIH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, letterSpacing: 2)),
              pw.SizedBox(height: 2),
              pw.Text("Silakan berkunjung kembali!", style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _separator() {
    return pw.Container(
      height: 1,
      width: double.infinity,
      color: PdfColors.grey600,
    );
  }

  static pw.Widget _rowText(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
