import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mobile_flutter/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  final Function(int)? onNavigate;
  const AdminDashboard({super.key, this.onNavigate});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  String _currentFilter = 'daily';
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({String? filter}) async {
    if (filter != null) {
      setState(() {
        _currentFilter = filter;
        _isLoading = true;
      });
    }
    try {
      final response = await _apiService.get('/dashboard?filter=${filter ?? _currentFilter}');
      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(dynamic value) {
    num val = 0;
    if (value is num) {
      val = value;
    } else if (value is String) {
      val = num.tryParse(value) ?? 0;
    }
    
    if (val >= 1000000) {
      return 'Rp ${(val / 1000000).toStringAsFixed(2)}jt';
    }
    
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchData(),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isTablet = constraints.maxWidth > 900;
                
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(constraints.maxWidth),
              const SizedBox(height: 24),
              _buildChartCard(),
              const SizedBox(height: 24),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRecentOrdersList()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildTopProductsList()),
                  ],
                )
              else ...[
                _buildRecentOrdersList(),
                const SizedBox(height: 24),
                _buildTopProductsList(),
              ],
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildHeader() {
    final user = _data['user'] ?? {};
    final storeName = _data['store_name'] ?? 'Warung Makan';
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, ${(user != null ? user['name'] : 'Admin') ?? 'Admin'}!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
              ),
              const SizedBox(height: 4),
              Text(
                storeName,
                style: const TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(double width) {
    final stats = _data['stats'] ?? {};
    int crossAxisCount = width > 900 ? 4 : 2;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Pesanan Hari Ini',
          stats['totalOrdersToday'].toString(),
          LucideIcons.shoppingBag,
          Colors.orange,
        ),
        _buildStatCard(
          'Pendapatan Hari Ini',
          _formatCurrency(stats['totalIncomeToday']),
          LucideIcons.wallet,
          Colors.green,
        ),
        _buildStatCard(
          'Meja Aktif',
          '${stats['activeTables']} / ${stats['totalTables']}',
          LucideIcons.users,
          Colors.blue,
        ),
        _buildStatCard(
          'Menu Terlaris',
          stats['popularProduct'] ?? '-',
          LucideIcons.award,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    final List<String> labels = (_data['labels'] as List? ?? []).map((e) => e.toString()).toList();
    final List<double> values = (_data['salesValues'] as List? ?? []).map((e) {
      if (e is num) return e.toDouble();
      return double.tryParse(e.toString()) ?? 0.0;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tren Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              _buildChartFilters(),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Text(labels[index], style: const TextStyle(color: AppColors.slate400, fontSize: 10, fontWeight: FontWeight.bold));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text('${(value / 1000000).toStringAsFixed(1)}jt', style: const TextStyle(color: AppColors.slate300, fontSize: 9, fontWeight: FontWeight.bold));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0)],
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

  Widget _buildChartFilters() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildFilterBtn('daily', 'Hari'),
          _buildFilterBtn('weekly', 'Minggu'),
          _buildFilterBtn('monthly', 'Bulan'),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String key, String label) {
    bool active = _currentFilter == key;
    return GestureDetector(
      onTap: () => _fetchData(filter: key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: active ? Colors.white : AppColors.slate400),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList() {
    final List orders = _data['recentOrders'] ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('5 Pesanan Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              TextButton(
                onPressed: () => widget.onNavigate?.call(1),
                child: Row(
                  children: [
                    Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            const Center(child: Text('Belum ada pesanan', style: TextStyle(color: AppColors.slate400)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 24, color: AppColors.slate50),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#ORD-${order['id'].toString().padLeft(3, '0')}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Row(
                          children: [
                            Text(order['name'] ?? 'Meja -', style: const TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: AppColors.slate200, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('${(order['items'] as List? ?? []).length} item', style: const TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusBadge(order['status']),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(order['total_price']),
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.amber;
        label = 'Baru';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildTopProductsList() {
    final List topProducts = _data['topProducts'] ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Produk Terpopuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          if (topProducts.isEmpty)
            const Center(child: Text('Data belum tersedia', style: TextStyle(color: AppColors.slate400)))
          else
            ...List.generate(topProducts.length, (index) {
              final item = topProducts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        (item['product'] != null ? item['product']['name'] : '-') ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item['total_sold']}x',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.slate400),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}