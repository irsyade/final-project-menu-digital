import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/product_controller.dart';
import 'package:intl/intl.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ProductController controller = Get.find<ProductController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  String _formatCurrency(dynamic value) {
    num val = 0;
    if (value is num) {
      val = value;
    } else if (value is String) {
      val = num.tryParse(value) ?? 0;
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grayish background to match mockup
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTopControls(context),
          _buildCategoryFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              List<dynamic> products = controller.products;
              
              // Filter by category
              if (_selectedCategory != 'Semua') {
                products = products.where((p) => p.categoryName == _selectedCategory).toList();
              }

              // Filter by search
              if (_searchController.text.isNotEmpty) {
                products = products.where((p) => p.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
              }

              if (products.isEmpty) {
                return const Center(child: Text('Tidak ada produk.', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold)));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1200 ? 5 : constraints.maxWidth > 900 ? 4 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8, // Adjusted for new card layout
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => _buildProductCard(context, products[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        'Pengaturan Kasir',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.slate900),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                  prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.slate400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Add Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showProductDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Tambah Produk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      final List<String> categories = ['Semua', ...controller.categories.map((c) => c.name)];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: categories.map((cat) {
            bool isActive = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? AppColors.primary : AppColors.slate200),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.slate600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: product.image != null 
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.image!, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.image, size: 32, color: AppColors.slate300),
                    ),
                  )
                : const Icon(LucideIcons.image, size: 32, color: AppColors.slate300),
            ),
          ),
          // Info Section
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.categoryName ?? '-',
                      style: const TextStyle(fontSize: 10, color: AppColors.slate500, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  // Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Toggle Switch
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Switch(
                          value: product.isAvailable,
                          onChanged: (val) => controller.toggleProductAvailability(product.id),
                          activeColor: Colors.green,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      // Action Icons
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showProductDialog(context, product: product),
                            child: const Icon(LucideIcons.edit2, size: 18, color: AppColors.slate400),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _confirmDelete(context, product),
                            child: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                          ),
                        ],
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
  }

  void _showProductDialog(BuildContext context, {dynamic product}) {
    final nameController = TextEditingController(text: product?.name ?? "");
    final priceController = TextEditingController(text: product?.price?.toString() ?? "");
    final descriptionController = TextEditingController(text: product?.description ?? "");
    final selectedCategoryId = RxInt(product?.categoryId ?? 0);
    final isAvailable = RxBool(product?.isAvailable ?? true);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product == null ? "Tambah Produk Baru" : "Edit Produk", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: AppColors.slate400),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 2-Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Photo)
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Foto Produk'),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2, style: BorderStyle.solid), // Fallback for dashed
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.uploadCloud, color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(height: 16),
                                const Text('Upload foto produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                const Text('JPG, PNG Max ukuran 10MB', style: TextStyle(color: AppColors.slate400, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right Column (Fields)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Nama Produk *'),
                          _buildTextField(nameController, 'Mis. Ayam Bakar Spesial'),
                          const SizedBox(height: 16),
                          _buildLabel('Deskripsi Produk'),
                          _buildTextField(descriptionController, 'Deskripsi singkat menu...', maxLines: 3),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Harga Asal (Opsional)'),
                                    _buildTextField(TextEditingController(), '38000', isNumber: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Harga Jual *'),
                                    _buildTextField(priceController, '35000', isNumber: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Cabang/Outlet'),
                                    _buildTextField(TextEditingController(), 'Pilih cabang'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Kategori *'),
                                    Obx(() => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.slate50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.slate200),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          value: selectedCategoryId.value == 0 ? null : selectedCategoryId.value,
                                          hint: const Text('Pilih', style: TextStyle(color: AppColors.slate400, fontSize: 14)),
                                          items: controller.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                                          onChanged: (val) => selectedCategoryId.value = val ?? 0,
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tags
                _buildLabel('Tag Filter'),
                Wrap(
                  spacing: 8,
                  children: ['Gurih', 'Pedas', 'Asam Manis', 'Sayuran', 'Vegan', 'Ayam', 'Daging Sapi', 'Seafood', 'Manis'].map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                // Ukuran Porsi
                _buildLabel('Ukuran Porsi'),
                Wrap(
                  spacing: 8,
                  children: ['1 Orang', 'Sharing (3-4)', 'Family (5-6)'].map((size) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: size == '1 Orang' ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: size == '1 Orang' ? AppColors.primary : AppColors.slate200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (size == '1 Orang') const Icon(LucideIcons.check, size: 14, color: AppColors.primary),
                        if (size == '1 Orang') const SizedBox(width: 4),
                        Text(size, style: TextStyle(fontSize: 12, color: size == '1 Orang' ? AppColors.primary : AppColors.slate500, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                // Bottom Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() => Switch(
                          value: isAvailable.value,
                          onChanged: (val) => isAvailable.value = val,
                          activeColor: Colors.green,
                        )),
                        const SizedBox(width: 8),
                        Text('Status Stok: ', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 14)),
                        Obx(() => Text(
                          isAvailable.value ? 'Tersedia' : 'Habis', 
                          style: TextStyle(color: isAvailable.value ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14)
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategoryId.value == 0) {
                              Get.snackbar("Peringatan", "Nama, Harga, dan Kategori harus diisi", backgroundColor: Colors.orange, colorText: Colors.white);
                              return;
                            }

                            final data = {
                              "name": nameController.text,
                              "category_id": selectedCategoryId.value,
                              "price": double.tryParse(priceController.text) ?? 0,
                              "description": descriptionController.text.isEmpty ? "-" : descriptionController.text,
                              "is_available": isAvailable.value,
                              if (product != null && product.image != null) "image": product.image,
                            };
                            
                            final result = product == null ? await controller.createProduct(data) : await controller.updateProduct(product.id, data);
                            
                            if (result['success']) {
                              Get.back();
                              Get.snackbar("Sukses", "Menu berhasil disimpan", backgroundColor: Colors.green, colorText: Colors.white);
                            } else {
                              Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Simpan Produk', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.slate700)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
        filled: true,
        fillColor: AppColors.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic product) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.trash2, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const Text('Hapus Menu?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.slate900)),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: AppColors.slate500, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Menu '),
                    TextSpan(text: '"${product.name}"', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    const TextSpan(text: ' akan dihapus permanen. QR code yang sudah dicetak tidak bisa digunakan kembali.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.slate200),
                      ),
                      child: const Text('Batal', style: TextStyle(color: AppColors.slate600, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await controller.deleteProduct(product.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Menu berhasil dihapus", backgroundColor: AppColors.primary, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Red matching mockup
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
