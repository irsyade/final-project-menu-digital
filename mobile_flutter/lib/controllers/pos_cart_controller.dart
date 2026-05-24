import 'package:get/get.dart';

class PosCartItem {
  final int id;
  final String name;
  final double price;
  var qty = 1.obs;

  PosCartItem({required this.id, required this.name, required this.price, int initialQty = 1}) {
    qty.value = initialQty;
  }

  double get subtotal => price * qty.value;
}

class PosCartController extends GetxController {
  var cartItems = <PosCartItem>[].obs;
  var selectedTable = 0.obs;

  void addItem(int id, String name, double price) {
    var existingItem = cartItems.firstWhereOrNull((item) => item.id == id);
    if (existingItem != null) {
      existingItem.qty.value++;
    } else {
      cartItems.add(PosCartItem(id: id, name: name, price: price));
    }
  }

  void removeItem(int id) {
    var existingItem = cartItems.firstWhereOrNull((item) => item.id == id);
    if (existingItem != null) {
      if (existingItem.qty.value > 1) {
        existingItem.qty.value--;
      } else {
        cartItems.remove(existingItem);
      }
    }
  }

  void deleteItem(int id) {
    cartItems.removeWhere((item) => item.id == id);
  }

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  void clearCart() {
    cartItems.clear();
  }
}
