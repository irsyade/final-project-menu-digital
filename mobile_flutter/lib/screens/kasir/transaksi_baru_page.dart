import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/pos_cart_controller.dart';
import 'package:mobile_flutter/controllers/kasir_controller.dart';
import 'package:mobile_flutter/controllers/product_controller.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/utils/debounce.dart';
import 'package:mobile_flutter/widgets/shimmer_loader.dart';

class TransaksiBaruPage extends StatefulWidget {
  TransaksiBaruPage({super.key});

  @override
  State<TransaksiBaruPage> createState() => _TransaksiBaruPageState();
}

class _TransaksiBaruPageState extends State<TransaksiBaruPage> {
  final ProductController productController = Get.find<ProductController>();
  final TableController tableController = Get.put(TableController());
  final RxInt activeCategoryIndex = 0.obs;
  final RxString searchQuery = "".obs;
  final _searchDebounce = Debounce(const Duration(milliseconds: 400));
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void dispose() {
    _searchDebounce.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pindahkan Get.find ke sini agar dipanggil saat build
    final PosCartController cartController = Get.find<PosCartController>();
    final KasirController kasirController = Get.find<KasirController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Stack(
            children: [
              // Product Browser
              Container(
                color: AppColors.background,
                child: Column(
                  children: [
                    _buildTopHeader(cartController),
                    _buildCategoryChips(),
                    Expanded(child: _buildProductGrid(cartController)),
                  ],
                ),
              ),
              
              // Mobile Cart Button
              Obx(() => cartController.cartItems.isNotEmpty ? Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: ElevatedButton(
                  onPressed: () => _showMobileCart(context, cartController, kasirController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.shoppingBag, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        "KERANJANG - ${cartController.cartItems.length} ITEM",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ) : const SizedBox.shrink()),
            ],
          );
        }

        return Row(
          children: [
            // Left Side: Product Browser (65%)
            Expanded(
              flex: 65,
              child: Container(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(cartController),
                    _buildCategoryChips(),
                    Expanded(child: _buildProductGrid(cartController)),
                  ],
                ),
              ),
            ),

            // Vertical Divider
            Container(width: 1, color: AppColors.slate200),

            // Right Side: Order Summary (35%)
            Expanded(
              flex: 35,
              child: _buildOrderPanel(cartController, kasirController),
            ),
          ],
        );
      },
    );
  }

  void _showMobileCart(BuildContext context, PosCartController cartController, KasirController kasirController) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: _buildOrderPanel(cartController, kasirController),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTopHeader(PosCartController cartController) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width < 360 ? 12 : 16,
        16, 
        MediaQuery.of(context).size.width < 360 ? 12 : 16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transaksi Baru",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 22,
                  color: AppColors.slate900,
                ),
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: cartController.selectedTable.value == 0 && tableController.tables.isNotEmpty 
                      ? tableController.tables.first.id 
                      : (cartController.selectedTable.value == 0 ? null : cartController.selectedTable.value),
                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Colors.white),
                    dropdownColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    items: tableController.tables.map((table) {
                      return DropdownMenuItem<int>(
                        value: table.id,
                        child: Text(
                          table.name ?? "Meja ${table.number}", 
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) cartController.selectedTable.value = val;
                    },
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchTextController,
              onChanged: (val) {
                searchQuery.value = val;
                _searchDebounce.run(() {
                  productController.searchProductsDebounced(val);
                });
              },
              decoration: InputDecoration(
                hintText: "Cari menu...",
                hintStyle: GoogleFonts.outfit(color: AppColors.slate400, fontWeight: FontWeight.bold),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.slate400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      final categories = ["Semua", ...productController.categories.map((c) => c.name)];
      return Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 24),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            bool isActive = activeCategoryIndex.value == index;
            return GestureDetector(
              onTap: () {
                activeCategoryIndex.value = index;
                if (index == 0) {
                  productController.fetchProducts();
                } else {
                  productController.selectCategory(productController.categories[index - 1].id);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  categories[index],
                  style: GoogleFonts.outfit(
                    color: isActive ? Colors.white : AppColors.slate500,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductGrid(PosCartController cartController) {
    return Obx(() {
      // Show shimmer during initial load OR debounced search
      if (productController.isLoading.value || productController.isSearching.value) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth < 400 ? 2 : 3);
            return ProductGridShimmer(count: crossCount * 2, crossAxisCount: crossCount);
          },
        );
      }

      final filteredProducts = productController.products.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase());
        return matchesSearch;
      }).toList();

      if (filteredProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.searchX, size: 56, color: AppColors.slate200),
              const SizedBox(height: 16),
              Text(
                "Menu tidak ditemukan",
                style: GoogleFonts.outfit(color: AppColors.slate400, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive: 2 columns on narrow mobile (<400px), 3 on wider
          final crossCount = constraints.maxWidth < 400 ? 2 : 3;
          final cardRadius = constraints.maxWidth < 400 ? 20.0 : 28.0;
          final childAspectRatio = constraints.maxWidth < 360
              ? 0.70
              : (constraints.maxWidth < 400 ? 0.75 : 0.78);

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 360 ? 12 : 16,
              0,
              constraints.maxWidth < 360 ? 12 : 16,
              100,
            ),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: constraints.maxWidth < 360 ? 8 : 12,
              mainAxisSpacing: constraints.maxWidth < 360 ? 8 : 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              bool isHabis = !product.isAvailable;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image — flexible height
                    Expanded(
                      flex: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildProductImage(product),
                          if (isHabis)
                            Container(
                              color: Colors.black.withOpacity(0.35),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "HABIS",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: AppColors.warning,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Product Info — compact padding
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Name
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: AppColors.slate800,
                                height: 1.2,
                              ),
                            ),
                            // Price + Add button row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    CurrencyFormat.convertToIdr(product.price, 0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.slate900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isHabis ? null : () => cartController.addItem(product.id, product.name, product.price),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isHabis ? AppColors.slate100 : AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: isHabis ? [] : [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      LucideIcons.plus,
                                      size: 14,
                                      color: isHabis ? AppColors.slate300 : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildOrderPanel(PosCartController cartController, KasirController kasirController) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 24,
        vertical: isSmall ? 20 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pesanan", 
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, 
              fontSize: isSmall ? 20 : 24,
              color: AppColors.slate900,
            )
          ),
          const SizedBox(height: 32),
          
          // Order List
          Expanded(
            child: Obx(() => cartController.cartItems.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.shoppingCart, size: 64, color: AppColors.slate200),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada pesanan", 
                        style: GoogleFonts.outfit(
                          color: AppColors.slate400, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  )
                )
              : ListView.separated(
                  itemCount: cartController.cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name, 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 15,
                                  color: AppColors.slate800,
                                )
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${CurrencyFormat.convertToIdr(item.price, 0)} x ${item.qty.value}", 
                                style: GoogleFonts.outfit(
                                  color: AppColors.slate400, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 12
                                )
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Counter
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => cartController.removeItem(item.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.slate200), 
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.qty.value > 1 ? LucideIcons.minus : LucideIcons.trash2, 
                                  size: 14, 
                                  color: item.qty.value > 1 ? AppColors.slate500 : Colors.red
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Obx(() => Text(
                                item.qty.value.toString(), 
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)
                              )),
                            ),
                            GestureDetector(
                              onTap: () => cartController.addItem(item.id, item.name, item.price),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary, 
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text(
                          CurrencyFormat.convertToIdr(item.price * item.qty.value, 0), 
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900, 
                            fontSize: 14,
                            color: AppColors.slate900,
                          )
                        ),
                      ],
                    );
                  },
                ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: AppColors.slate100),
          const SizedBox(height: 24),

          // Summary
          Obx(() => Column(
            children: [
              _buildSummaryRow("Subtotal", CurrencyFormat.convertToIdr(cartController.subtotal, 0)),
              const SizedBox(height: 16),
              _buildSummaryRow("Pajak (10%)", CurrencyFormat.convertToIdr(cartController.tax, 0)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total", 
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, 
                      fontSize: 20,
                      color: AppColors.slate900,
                    )
                  ),
                  Text(
                    CurrencyFormat.convertToIdr(cartController.total, 0), 
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, 
                      fontSize: 24, 
                      color: AppColors.primary
                    )
                  ),
                ],
              ),
            ],
          )),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (cartController.cartItems.isNotEmpty) {
                  kasirController.changeIndex(2);
                } else {
                  Get.snackbar(
                    "Peringatan", 
                    "Keranjang masih kosong",
                    backgroundColor: AppColors.warning.withOpacity(0.1),
                    colorText: AppColors.warning,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 16,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 22),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 15,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: Text(
                "Lanjut ke Pembayaran", 
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900, 
                  fontSize: isSmall ? 15 : 18, 
                  letterSpacing: 0.5,
                  color: Colors.white,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(
            color: AppColors.slate400, 
            fontWeight: FontWeight.w900,
            fontSize: 14,
          )
        ),
        Text(
          value, 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColors.slate700,
          )
        ),
      ],
    );
  }

  Widget _buildProductImage(dynamic product) {
    String imageUrl = product.image ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.slate100,
          child: const Icon(LucideIcons.image, color: AppColors.slate300, size: 40),
        );
      },
    );
  }
}