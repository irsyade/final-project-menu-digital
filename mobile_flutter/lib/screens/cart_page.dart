import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/cart_controller.dart';
import 'package:mobile_flutter/screens/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Keranjang Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.slate900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shoppingCart, size: 64, color: AppColors.slate200),
                const SizedBox(height: 16),
                Text(
                  'Keranjang Anda masih kosong.',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Mulai Belanja'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDesign.radiusM),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: [AppDesign.shadow],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.product.image ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.slate900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormat.convertToIdr(item.product.price, 0),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: 18,
                                icon: Icon(LucideIcons.minus),
                                color: AppColors.slate500,
                                onPressed: () => controller.updateQuantity(item, -1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.slate900,
                                ),
                              ),
                              IconButton(
                                iconSize: 18,
                                icon: Icon(LucideIcons.plus),
                                color: AppColors.primary,
                                onPressed: () => controller.updateQuantity(item, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesign.radiusXL)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate900.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(controller.subtotal, 0),
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(controller.total, 0),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const CheckoutPage()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slate900,
                          elevation: 10,
                          shadowColor: AppColors.slate900.withOpacity(0.3),
                        ),
                        child: const Text(
                          'LANJUTKAN PEMBAYARAN',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}