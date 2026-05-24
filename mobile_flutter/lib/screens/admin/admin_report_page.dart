import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/report_controller.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  final ReportController controller = Get.find<ReportController>();

  String _formatCurrency(dynamic value) {
    double val = double.tryParse(value?.toString() ?? '0') ?? 0;
    if (val >= 1000000) return 'Rp ${(val / 1000000).toStringAsFixed(1)}jt';
    if (val >= 1000) return 'Rp ${(val / 1000).toStringAsFixed(0)}rb';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFA),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTimeFilter(),
              _buildStatsGrid(),
              _buildTrendChart(),
              _buildTopProducts(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laporan Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900)),
            Text('Ringkasan performa toko Anda', style: TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          onPressed: () => _showExportModal(context),
          style: IconButton.styleFrom(backgroundColor: AppColors.slate50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(LucideIcons.download, color: AppColors.slate900, size: 20),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildFilterItem('Harian', 'daily'),
          _buildFilterItem('Mingguan', 'weekly'),
          _buildFilterItem('Bulanan', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String value) {
    bool isActive = controller.selectedFilter.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.fetchReportData(filter: value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? Colors.white : AppColors.slate400),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          _buildDatePickerBox('1 April 2025'),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('-', style: TextStyle(color: AppColors.slate300))),
          _buildDatePickerBox('27 April 2025'),
        ],
      ),
    );
  }

  Widget _buildDatePickerBox(String date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate100)),
        child: Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate900)),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = controller.stats;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 4 : 2,
            childAspectRatio: isTablet ? 2.2 : 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('Total Pendapatan', _formatCurrency(stats['totalIncomeToday']), true, isTablet),
              _buildStatCard('Pesanan Hari Ini', stats['totalOrdersToday']?.toString() ?? '0', true, isTablet),
              _buildStatCard('Rata-rata/Pesanan', _formatCurrency(67000), false, isTablet),
              _buildStatCard('Menu Aktif', '24', false, isTablet),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, bool isPrimary, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 16),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPrimary ? AppColors.primary : AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: isTablet ? 8 : 9, color: isPrimary ? Colors.white70 : AppColors.slate400, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: isTablet ? 14 : 16, fontWeight: FontWeight.w900, color: isPrimary ? Colors.white : AppColors.slate900)),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tren Penjualan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
          const Text('Periode: 1 Apr - 27 Apr 2025', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: AppColors.slate50, strokeWidth: 1)),
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
                        int index = value.toInt();
                        if (index < 0 || index >= controller.chartLabels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(controller.chartLabels[index], style: const TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold, fontSize: 8)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500000,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text('${(value / 1000000).toStringAsFixed(1)}jt', style: const TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold, fontSize: 8));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (controller.chartValues.length - 1).toDouble(),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.chartValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top 5 Menu Terlaris', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
          const Text('Periode: 1 Apr - 27 Apr 2025', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...controller.topProducts.asMap().entries.map((e) => _buildTopProductItem(e.key + 1, e.value)).toList(),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(int rank, dynamic data) {
    final product = data['product'];
    final sold = data['total_sold'];
    final revenue = (double.tryParse(product?['price']?.toString() ?? '0') ?? 0) * (double.tryParse(sold.toString()) ?? 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            child: Center(child: Text(rank.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.utensilsCrossed, size: 16, color: AppColors.slate300),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product?['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.slate900)),
                    Text(_formatCurrency(revenue), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$sold pesanan', style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                    // Fake progress bar logic
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 4, width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(2)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (6 - rank) / 5, // Simple visual scale
                    child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportModal(BuildContext context) {
    var selectedFormat = 'PDF'.obs;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Export Laporan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, size: 20)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Format', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                Expanded(child: _buildFormatButton('CSV', selectedFormat.value == 'CSV', () => selectedFormat.value = 'CSV')),
                const SizedBox(width: 12),
                Expanded(child: _buildFormatButton('PDF', selectedFormat.value == 'PDF', () => selectedFormat.value = 'PDF')),
              ],
            )),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Periode: 1 Apr - 27 Apr 2025', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                  const SizedBox(height: 4),
                  Text('Mode: ${controller.selectedFilter.value.capitalizeFirst}', style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
              icon: const Icon(LucideIcons.download, color: Colors.white, size: 20),
              label: const Text('Download Laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.orange : AppColors.slate100),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? Colors.orange : AppColors.slate400))),
      ),
    );
  }
}
