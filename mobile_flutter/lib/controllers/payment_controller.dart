import 'package:get/get.dart';

class PaymentController extends GetxController {
  var selectedTab = 0.obs; // 0: Tunai, 1: QRIS, 2: Split Bill
  var uangDiterima = 0.0.obs;
  var isSuccess = false.obs;
  
  // Split Bill
  var splitCount = 2.obs;

  void appendNumpad(String val) {
    String current = uangDiterima.value.toInt().toString();
    if (current == "0") current = "";
    
    if (val == "backspace") {
      if (current.isNotEmpty) {
        current = current.substring(0, current.length - 1);
      }
    } else {
      current += val;
    }
    
    uangDiterima.value = double.tryParse(current) ?? 0.0;
  }

  void setQuickAmount(double amount) {
    uangDiterima.value = amount;
  }

  void processPayment() {
    isSuccess.value = true;
  }

  void resetPayment() {
    isSuccess.value = false;
    uangDiterima.value = 0.0;
    selectedTab.value = 0;
  }
}
