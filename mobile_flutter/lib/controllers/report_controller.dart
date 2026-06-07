import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/services/report_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class ReportController extends GetxController {
  final ReportService _reportService = ReportService();

  var isLoading = false.obs;
  var isDownloading = false.obs;
  var stats = {}.obs;
  var chartLabels = <String>[].obs;
  var chartValues = <double>[].obs;
  var topProducts = <dynamic>[].obs;
  var selectedFilter = 'daily'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReportData();
  }

  Future<void> fetchReportData({String? filter}) async {
    isLoading(true);
    if (filter != null) selectedFilter.value = filter;

    try {
      final data = await _reportService.getReportData(selectedFilter.value);
      if (data != null) {
        stats.value = data['stats'] ?? {};
        chartLabels.value = List<String>.from(data['labels'] ?? []);
        final rawValues = data['salesValues'] ?? data['chartData'] ?? [];
        chartValues.value = List<double>.from(
          (rawValues as List).map((v) => double.tryParse(v.toString()) ?? 0.0),
        );
        topProducts.value = data['topProducts'] ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching report data: $e");
    } finally {
      isLoading(false);
    }
  }

  // ─── Fetch store info from settings API ───────────────────────────────────
  
  Future<Map<String, String>> _fetchStoreInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/settings'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

  // ─── Download PDF ──────────────────────────────────────────────────────────

  Future<void> downloadReport(String format) async {
    if (isDownloading.value) return;
    isDownloading(true);

    try {
      final pdfBytes = await _buildReportPdf();
      final period = _periodLabel(selectedFilter.value);
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'laporan-penjualan-$period.pdf',
      );
    } catch (e) {
      debugPrint("downloadReport error: $e");
      Get.snackbar(
        "Gagal",
        "Gagal membuat PDF: $e",
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading(false);
    }
  }

  // ─── PDF builder ──────────────────────────────────────────────────────────

  Future<Uint8List> _buildReportPdf() async {
    // Fetch restaurant info from settings API
    final storeInfo = await _fetchStoreInfo();
    final restaurantName = storeInfo['site_name'] ?? 'MenuKu Resto';
    final restaurantAddress = storeInfo['address'] ?? '';

    final doc  = pw.Document();
    final now  = DateTime.now();
    final fmt  = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('d MMMM yyyy', 'id');

    final totalRevenue = double.tryParse(
          stats['totalIncomeToday']?.toString() ?? '0') ?? 0;
    final totalOrders = stats['totalOrdersToday']?.toString() ?? '0';
    final periodLabel = _periodLabel(selectedFilter.value);

    // Brand colour as PDF colour
    const brandColor = PdfColor.fromInt(0xFFE8781A);
    const darkColor  = PdfColor.fromInt(0xFF0F172A);
    const grayColor  = PdfColor.fromInt(0xFF64748B);
    const lightGray  = PdfColor.fromInt(0xFFF1F5F9);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: lightGray, width: 1)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(restaurantName,
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: brandColor)),
                  pw.Text('Laporan Penjualan',
                      style: const pw.TextStyle(fontSize: 11, color: grayColor)),
                  if (restaurantAddress.isNotEmpty)
                    pw.Text(restaurantAddress,
                        style: const pw.TextStyle(fontSize: 9, color: grayColor)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Dicetak: ${dateFmt.format(now)}',
                      style: const pw.TextStyle(fontSize: 9, color: grayColor)),
                  pw.Text('Filter: ${_periodLabelFull(selectedFilter.value)}',
                      style: const pw.TextStyle(fontSize: 9, color: grayColor)),
                ],
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: lightGray, width: 1)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('© ${now.year} MenuKu',
                  style: const pw.TextStyle(fontSize: 8, color: grayColor)),
              pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: grayColor)),
            ],
          ),
        ),
        build: (ctx) => [
          // ── Title ──────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Text(
              'Ringkasan Penjualan – ${_periodLabelFull(selectedFilter.value)}',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor),
            ),
          ),

          // ── Summary cards ─────────────────────────────────────────────────
          pw.Row(
            children: [
              _pdfCard('Total Pendapatan', fmt.format(totalRevenue),
                  brandColor, pw.FlexColumnWidth(1.4)),
              pw.SizedBox(width: 12),
              _pdfCard('Total Pesanan', totalOrders, darkColor,
                  pw.FlexColumnWidth(1)),
              pw.SizedBox(width: 12),
              _pdfCard(
                  'Rata-rata/Hari',
                  totalOrders != '0'
                      ? fmt.format(totalRevenue /
                          (int.tryParse(totalOrders) ?? 1))
                      : 'Rp 0',
                  grayColor,
                  pw.FlexColumnWidth(1)),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── Top Products ──────────────────────────────────────────────────
          if (topProducts.isNotEmpty) ...[
            pw.Text('Top Menu Terlaris',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor)),
            pw.SizedBox(height: 10),

            // Table header
            pw.Container(
              color: lightGray,
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('#',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                  pw.Expanded(
                      flex: 5,
                      child: pw.Text('Menu',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('Terjual',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Pendapatan',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                ],
              ),
            ),

            // Table rows
            ...topProducts.asMap().entries.map((entry) {
              final i       = entry.key;
              final item    = entry.value;
              final product = item['product'];
              final sold    = double.tryParse(
                      item['total_sold']?.toString() ?? '0') ??
                  0;
              final price   = double.tryParse(
                      product?['price']?.toString() ?? '0') ??
                  0;
              final revenue = price * sold;
              final isEven  = i % 2 == 0;

              return pw.Container(
                color: isEven ? PdfColors.white : lightGray,
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('${i + 1}',
                            style: const pw.TextStyle(
                                fontSize: 9, color: grayColor))),
                    pw.Expanded(
                        flex: 5,
                        child: pw.Text(
                            product?['name']?.toString() ?? '-',
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: darkColor))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('${sold.toInt()} pesanan',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                                fontSize: 9, color: grayColor))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(fmt.format(revenue),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: brandColor))),
                  ],
                ),
              );
            }).toList(),

            pw.SizedBox(height: 24),
          ],

          // ── Sales chart data as table ─────────────────────────────────────
          if (chartLabels.isNotEmpty) ...[
            pw.Text('Data Penjualan Per Periode',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor)),
            pw.SizedBox(height: 10),

            pw.Container(
              color: lightGray,
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Periode',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Pendapatan',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: grayColor))),
                ],
              ),
            ),

            ...chartLabels.asMap().entries.map((entry) {
              final i      = entry.key;
              final label  = entry.value;
              final value  = i < chartValues.length
                  ? chartValues[i]
                  : 0.0;
              final isEven = i % 2 == 0;

              return pw.Container(
                color: isEven ? PdfColors.white : lightGray,
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(label,
                            style: const pw.TextStyle(
                                fontSize: 9, color: grayColor))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text(fmt.format(value),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: darkColor))),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  pw.Widget _pdfCard(
      String label, String value, PdfColor color, pw.FlexColumnWidth flex) {
    return pw.Flexible(
      flex: flex.flex.toInt(),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white)),
          ],
        ),
      ),
    );
  }

  String _periodLabel(String filter) {
    switch (filter) {
      case 'weekly':  return 'mingguan';
      case 'monthly': return 'bulanan';
      default:        return 'harian';
    }
  }

  String _periodLabelFull(String filter) {
    switch (filter) {
      case 'weekly':  return 'Mingguan';
      case 'monthly': return 'Bulanan';
      default:        return 'Harian';
    }
  }
}
