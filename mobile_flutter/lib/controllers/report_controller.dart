import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile_flutter/services/api_service.dart';

class ReportController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
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
      final response = await _apiService.get('/dashboard?filter=${selectedFilter.value}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stats.value = data['stats'];
        chartLabels.value = List<String>.from(data['labels']);
        chartValues.value = List<double>.from(data['salesValues'].map((v) => double.parse(v.toString())));
        topProducts.value = data['topProducts'];
      }
    } catch (e) {
      print("Error fetching report data: $e");
    } finally {
      isLoading(false);
    }
  }
}
