import 'package:get/get.dart';
import 'package:mobile_flutter/models/cart_item.dart';
import 'package:mobile_flutter/models/product.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  
  // Example dummy fee and tax
  double get bagFee => 0.25;
  double get serviceFee => 0.55;
  double get total => subtotal + bagFee + serviceFee;

  void addToCart(Product product, int quantity) {
    if (quantity <= 0) return;
    
    int index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch, // temporary local ID
        product: product,
        quantity: quantity,
      ));
    }
    
    Get.snackbar(
      'Success',
      '${product.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  void updateQuantity(CartItem item, int change) {
    int newQty = item.quantity + change;
    if (newQty > 0) {
      item.quantity = newQty;
      cartItems.refresh();
    } else if (newQty == 0) {
      cartItems.remove(item);
      cartItems.refresh();
    }
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
  }

  void clearCart() {
    cartItems.clear();
  }
}
