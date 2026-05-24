import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/product_controller.dart';

class CategoryManagementPage extends StatelessWidget {
  CategoryManagementPage({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.slate900),
        title: Text(
          "Kelola Kategori", 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900, 
            color: AppColors.slate900,
            fontSize: 24,
          )
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Category Icon Box
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0), // Light peach
                      borderRadius: BorderRadius.circular(16),
                      image: category.image != null ? DecorationImage(image: NetworkImage(category.image!), fit: BoxFit.cover) : null,
                    ),
                    child: category.image == null 
                      ? const Center(child: Icon(LucideIcons.tag, color: Color(0xFFE67E22), size: 28)) 
                      : null,
                  ),
                  const SizedBox(width: 20),
                  // Category Info
                  Expanded(
                    child: Text(
                      category.name, 
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, 
                        fontSize: 18,
                        color: AppColors.slate900,
                      )
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, size: 24, color: AppColors.slate600),
                        onPressed: () => _showCategoryDialog(context, category: category),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 24, color: Color(0xFFE74C3C)), // Red
                        onPressed: () => _confirmDelete(category.id),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: () => _showCategoryDialog(context),
          backgroundColor: const Color(0xFFE67E22),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {dynamic category}) {
    final nameController = TextEditingController(text: category?.name ?? "");

    Get.dialog(
      AlertDialog(
        title: Text(category == null ? "Tambah Kategori" : "Edit Kategori", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Kategori")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final data = {"name": nameController.text};
              bool success;
              if (category == null) {
                success = await controller.createCategory(data);
              } else {
                success = await controller.updateCategory(category.id, data);
              }

              if (success) {
                Get.back();
                Get.snackbar("Sukses", "Kategori berhasil disimpan");
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Hapus Kategori?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              bool success = await controller.deleteCategory(id);
              if (success) {
                Get.back();
                Get.snackbar("Sukses", "Kategori berhasil dihapus");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
