import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/services/api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  // ─── Dashboard / chart data ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> getReportData(String filter) async {
    final period = _toPeriod(filter);
    try {
      final response = await _apiService.get('/dashboard?filter=$period');
      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        if (raw is Map<String, dynamic>) {
          return _normalizeReportData(raw);
        }
      }
      debugPrint('getReportData failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('getReportData error: $e');
    }
    return null;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _toPeriod(String filter) {
    switch (filter) {
      case 'weekly':  return 'week';
      case 'monthly': return 'month';
      default:        return 'day';
    }
  }

  Map<String, dynamic> _normalizeReportData(Map<String, dynamic> raw) {
    final stats = <String, dynamic>{};
    stats['totalIncomeToday'] = raw['totalRevenue']  ?? raw['total_revenue']  ?? 0;
    stats['totalOrdersToday'] = raw['totalOrders']   ?? raw['total_orders']   ?? 0;
    stats['averagePerDay']    = raw['averagePerDay'] ?? raw['average_per_day'] ?? 0;

    final labels = List<String>.from(raw['chartLabels'] ?? raw['labels'] ?? []);
    final values = List<dynamic>.from(raw['chartData']  ?? raw['salesValues'] ?? []);

    final topRaw = List<dynamic>.from(raw['topMenus'] ?? raw['topProducts'] ?? []);
    final topProducts = topRaw.map((item) {
      if (item is Map && item.containsKey('product')) return item;
      return {
        'product': {
          'name': item['name'] ?? '-',
          'price': (item['revenue'] != null &&
                  item['qty'] != null &&
                  (item['qty'] as num) > 0)
              ? ((item['revenue'] as num) / (item['qty'] as num)).round()
              : 0,
        },
        'total_sold': item['qty'] ?? item['total_qty'] ?? 0,
      };
    }).toList();

    return {
      'stats':       stats,
      'labels':      labels,
      'salesValues': values,
      'topProducts': topProducts,
    };
  }
}
