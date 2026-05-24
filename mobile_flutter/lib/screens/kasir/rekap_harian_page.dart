import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:mobile_flutter/controllers/order_controller.dart';
import 'package:mobile_flutter/controllers/auth_controller.dart';

class RekapHarianPage extends StatelessWidget {
  RekapHarianPage({super.key});

  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 32),
                _buildSummaryCards(isMobile),
                const SizedBox(height: 24),
                _buildChartsRow(isMobile),
                const SizedBox(height: 24),
                _buildTopMenuTable(isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    String today = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rekap Harian", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.slate900)),
            const SizedBox(height: 4),
            Text(today, style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 14)),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {
            Get.snackbar(
              "Export PDF",
              "Fitur export PDF sedang dalam pengembangan",
              backgroundColor: AppColors.slate900,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(24),
            );
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: Text("Export PDF", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.slate700,
            side: const BorderSide(color: AppColors.slate300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(bool isMobile) {
    return Obx(() {
      final data = orderController.dashboardData;
      final revenue = double.tryParse(data['stats']?['totalIncomeToday']?.toString() ?? "0") ?? 2450000.0;
      final totalOrders = data['stats']?['totalOrdersToday'] ?? 47;
      final topProducts = data['topProducts'] ?? [];
      String topMenuName = "Ayam Bakar";
      int topMenuQty = 142;
      if (topProducts.isNotEmpty) {
        topMenuName = topProducts[0]['product']?['name'] ?? topProducts[0]['product_name'] ?? topMenuName;
        topMenuQty = int.tryParse(topProducts[0]['total_sold']?.toString() ?? "") ?? topMenuQty;
      }
      
      final pendingOrders = 3; // Mock

      if (isMobile) {
        return Column(
          children: [
            _summaryCard("Total Penjualan", CurrencyFormat.convertToIdr(revenue, 0), "+ 12% vs kemarin", LucideIcons.trendingUp, const Color(0xFFF97316), const Color(0xFFFFF7ED), isPositive: true),
            const SizedBox(height: 16),
            _summaryCard("Jumlah Pesanan", totalOrders.toString(), "hari ini", LucideIcons.shoppingBag, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
            const SizedBox(height: 16),
            _summaryCard("Menu Terlaris", topMenuName, "${topMenuQty}x terjual", LucideIcons.bookmark, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
            const SizedBox(height: 16),
            _summaryCard("Pesanan Pending", pendingOrders.toString(), "perlu diproses", LucideIcons.alertCircle, const Color(0xFFEF4444), const Color(0xFFFEF2F2), isWarning: true),
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: _summaryCard("Total Penjualan", CurrencyFormat.convertToIdr(revenue, 0), "+ 12% vs kemarin", LucideIcons.trendingUp, const Color(0xFFF97316), const Color(0xFFFFF7ED), isPositive: true)),
          const SizedBox(width: 16),
          Expanded(child: _summaryCard("Jumlah Pesanan", totalOrders.toString(), "hari ini", LucideIcons.shoppingBag, const Color(0xFF3B82F6), const Color(0xFFEFF6FF))),
          const SizedBox(width: 16),
          Expanded(child: _summaryCard("Menu Terlaris", topMenuName, "${topMenuQty}x terjual", LucideIcons.bookmark, const Color(0xFFF59E0B), const Color(0xFFFEF3C7))),
          const SizedBox(width: 16),
          Expanded(child: _summaryCard("Pesanan Pending", pendingOrders.toString(), "perlu diproses", LucideIcons.alertCircle, const Color(0xFFEF4444), const Color(0xFFFEF2F2), isWarning: true)),
        ],
      );
    });
  }

  Widget _summaryCard(String title, String value, String subtitle, IconData icon, Color iconColor, Color iconBg, {bool isPositive = false, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.outfit(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 22, color: title == "Total Penjualan" || title == "Pesanan Pending" ? iconColor : AppColors.slate900)),
          const SizedBox(height: 8),
          if (isPositive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
              child: Text(subtitle, style: GoogleFonts.outfit(color: const Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            Text(subtitle, style: GoogleFonts.outfit(color: isWarning ? const Color(0xFFEF4444) : AppColors.slate400, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartsRow(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildLineChartCard(),
          const SizedBox(height: 24),
          _buildBarChartCard(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _buildLineChartCard()),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: _buildBarChartCard()),
      ],
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.slate200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tren Penjualan", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.slate900)),
                  Text("7 hari terakhir", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Text("Mingguan", style: GoogleFonts.outfit(color: const Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFFEA580C)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.slate100, strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.slate400, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Sen', style: style); break;
                          case 1: text = const Text('Sel', style: style); break;
                          case 2: text = const Text('Rab', style: style); break;
                          case 3: text = const Text('Kam', style: style); break;
                          case 4: text = const Text('Jum', style: style); break;
                          case 5: text = const Text('Sab', style: style); break;
                          case 6: text = const Text('Min', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text("${value.toInt()}Jt", style: const TextStyle(color: AppColors.slate400, fontSize: 11));
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 6,
                minY: 0, maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 2), FlSpot(2, 5), FlSpot(3, 5),
                      FlSpot(4, 6), FlSpot(5, 4), FlSpot(6, 8),
                    ],
                    isCurved: true,
                    color: const Color(0xFFF97316),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFFF97316).withOpacity(0.2), const Color(0xFFF97316).withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.slate200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Penjualan per Kategori", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.slate900)),
          Text("Bulan ini", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text("${value.toInt()}k", style: const TextStyle(color: AppColors.slate400, fontSize: 11));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.bold);
                        String text = '';
                        switch (value.toInt()) {
                          case 0: text = 'Lainnya'; break;
                          case 1: text = 'Minuman'; break;
                          case 2: text = 'Makanan'; break;
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: false,
                  getDrawingVerticalLine: (value) => FlLine(color: AppColors.slate100, strokeWidth: 1, dashArray: [5, 5]),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [BarChartRodData(toY: 10, color: const Color(0xFF94A3B8), width: 24, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [BarChartRodData(toY: 30, color: const Color(0xFF10B981), width: 24, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [BarChartRodData(toY: 85, color: const Color(0xFFEA580C), width: 24, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                  ),
                ],
                maxY: 100,
                groupsSpace: 12,
              ),
              swapAnimationDuration: Duration.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenuTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.slate200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Top 5 Menu Terlaris", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.slate900)),
                    Text("Berdasarkan jumlah terjual", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Text("Bulan Ini", style: GoogleFonts.outfit(color: const Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFFEA580C)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: AppColors.slate50,
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text("#", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                  Expanded(flex: 3, child: Text("MENU", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                  Expanded(flex: 2, child: Text("KATEGORI", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                  Expanded(flex: 2, child: Text("TERJUAL", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                  Expanded(flex: 2, child: Text("PENDAPATAN", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                  Expanded(flex: 2, child: Text("KONTRIBUSI", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate500))),
                ],
              ),
            ),
          Obx(() {
            final data = orderController.dashboardData;
            final List topProducts = data['topProducts'] ?? [];

            if (topProducts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text("Belum ada data penjualan.", style: GoogleFonts.outfit(color: AppColors.slate500))),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length > 5 ? 5 : topProducts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.slate100),
              itemBuilder: (context, index) {
                var item = topProducts[index];
                String name = item['product']?['name'] ?? item['product_name'] ?? "Unknown Menu";
                int qty = int.tryParse(item['total_sold']?.toString() ?? "0") ?? 0;
                double revenue = double.tryParse(item['total_revenue']?.toString() ?? "0") ?? (qty * 25000.0);
                double contribution = index == 0 ? 1.0 : (index == 1 ? 0.7 : (index == 2 ? 0.5 : 0.3)); // Mock calculation if not from API
                
                if (isMobile) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: const Color(0xFFEA580C), borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text("${index + 1}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("Kategori: Makanan • Terjual: $qty", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(CurrencyFormat.convertToIdr(revenue, 0), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Container(
                          width: 28, height: 28,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? const Color(0xFFF97316) : (index == 1 ? const Color(0xFFFDBA74) : AppColors.slate100)),
                          child: Center(child: Text("${index + 1}", style: GoogleFonts.outfit(color: index < 2 ? Colors.white : AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                      ),
                      Expanded(flex: 3, child: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.slate900))),
                      Expanded(flex: 2, child: Text("Makanan", style: GoogleFonts.outfit(color: const Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 13))),
                      Expanded(flex: 2, child: Text("${qty}x", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.slate900))),
                      Expanded(flex: 2, child: Text(CurrencyFormat.convertToIdr(revenue, 0), style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold))),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(child: LinearProgressIndicator(value: contribution, backgroundColor: AppColors.slate100, color: const Color(0xFFF97316), minHeight: 6, borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 8),
                            Text("${(contribution * 100).toInt()}%", style: GoogleFonts.outfit(color: AppColors.slate500, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
