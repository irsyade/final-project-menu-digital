import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/promo_controller.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/models/promo.dart';
import 'package:image_picker/image_picker.dart';

class AdminPromoPage extends StatefulWidget {
  const AdminPromoPage({super.key});

  @override
  State<AdminPromoPage> createState() => _AdminPromoPageState();
}

class _AdminPromoPageState extends State<AdminPromoPage> {
  final PromoController controller = Get.find<PromoController>();
  String _selectedFilter = 'Semua';
  bool _showPromoAlert = true;

  @override
  void initState() {
    super.initState();
    controller.fetchPromos();
  }

  String _formatCurrency(dynamic value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchPromos();
                  },
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var filteredPromos = controller.promos.where((p) {
                      if (_selectedFilter == 'Semua') return true;
                      if (_selectedFilter == 'Aktif') return p.isActive;
                      if (_selectedFilter == 'Nonaktif') return !p.isActive;
                      if (_selectedFilter == 'Terjadwal') return p.startDate != null && p.startDate!.isAfter(DateTime.now());
                      if (_selectedFilter == 'Kadaluarsa') return p.endDate != null && p.endDate!.isBefore(DateTime.now());
                      return true;
                    }).toList();

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBannerSection(),
                          _buildPromoAlert(),
                          _buildFilters(),
                          if (filteredPromos.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Tidak ada promo.', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold))))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              itemCount: filteredPromos.length,
                              itemBuilder: (context, index) => _buildPromoCard(filteredPromos[index]),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Promo & Jadwal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900)),
          IconButton(
            onPressed: () => _showAddPromoDialog(context),
            icon: Icon(LucideIcons.plus, color: AppColors.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    final banners = controller.promos.where((p) => p.isBanner).toList();
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: banners.length,
            itemBuilder: (context, index) => _buildBannerItem(banners[index]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? AppColors.primary : AppColors.slate200),
          )),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBannerItem(Promo promo) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        image: promo.image != null ? DecorationImage(image: NetworkImage(promo.image!), fit: BoxFit.cover) : null,
      ),
      child: promo.image == null ? const Icon(LucideIcons.image, color: AppColors.slate200) : null,
    );
  }

  Widget _buildPromoAlert() {
    if (!_showPromoAlert) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 14, color: AppColors.slate400),
          const SizedBox(width: 8),
          const Expanded(child: Text('Promo kadaluarsa dihapus otomatis oleh sistem', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold))),
          IconButton(
            onPressed: () {
              setState(() {
                _showPromoAlert = false;
              });
            },
            icon: const Icon(LucideIcons.x, size: 14, color: AppColors.slate400),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Semua', 'Aktif', 'Nonaktif', 'Terjadwal', 'Kadaluarsa'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: filters.map((f) {
          bool isActive = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.slate200),
              ),
              child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isActive ? Colors.white : AppColors.slate400)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPromoCard(Promo promo) {
    Color typeColor = Colors.orange;
    if (promo.promoType == 'bundling') typeColor = Colors.blue;

    bool isExpired = promo.endDate != null && promo.endDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(promo.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
              Text(isExpired ? 'Kadaluarsa' : 'Aktif', style: TextStyle(color: isExpired ? Colors.red : AppColors.success, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(promo.promoType.capitalizeFirst!, style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(promo.type == 'percentage' ? '${promo.value.toInt()}%' : _formatCurrency(promo.value), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_formatDate(promo.startDate)} - ${_formatDate(promo.endDate)}', style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Min. ${_formatCurrency(promo.minPurchase)}', style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Sisa: ${promo.quota != null ? (promo.quota! - promo.used) : '∞'} pakai', style: const TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 24, width: 40,
                child: Switch(value: promo.isActive, onChanged: (val) => controller.togglePromoStatus(promo.id), activeColor: AppColors.success),
              ),
              Row(
                children: [
                  IconButton(onPressed: () => _showAddPromoDialog(context, promo: promo), icon: const Icon(LucideIcons.edit, size: 16, color: AppColors.slate400), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                  const SizedBox(width: 16),
                  IconButton(onPressed: () => _confirmDelete(promo), icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPromoDialog(BuildContext context, {Promo? promo}) {
    final nameController = TextEditingController(text: promo?.name ?? "");
    final descController = TextEditingController(text: promo?.description ?? "");
    final codeController = TextEditingController(text: promo?.code ?? "");
    final quotaController = TextEditingController(text: promo?.quota?.toString() ?? "");
    final valueController = TextEditingController(text: promo?.value?.toString() ?? "");
    final minPurchaseController = TextEditingController(text: promo?.minPurchase?.toString() ?? "");
    final bundlingItemsController = TextEditingController(text: promo?.bundlingItems ?? "");
    final freeItemNameController = TextEditingController(text: promo?.freeItemName ?? "");
    
    var promoType = (promo?.promoType ?? 'diskon').obs;
    var discountType = (promo?.type ?? 'percentage').obs; // percentage or fixed
    var startDate = (promo?.startDate ?? DateTime.now()).obs;
    var endDate = (promo?.endDate ?? DateTime.now().add(const Duration(days: 30))).obs;
    final pickedImagePath = RxnString(null);

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(promo == null ? 'Tambah Promo' : 'Edit Promo', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Foto Iklan Promo (opsional)'),
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    pickedImagePath.value = image.path;
                  }
                },
                child: Obx(() {
                  final path = pickedImagePath.value;
                  final hasExistingImage = promo != null && promo.image != null;

                  if (path != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(path),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else if (hasExistingImage) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        promo.image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.image, size: 32, color: AppColors.slate300),
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity, height: 160,
                    decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.slate100)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.uploadCloud, color: AppColors.slate300, size: 32),
                        SizedBox(height: 12),
                        Text('Upload Iklan Promo', style: TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('(JPG, PNG, Maks. 10MB)', style: TextStyle(color: AppColors.slate200, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildLabel('Nama Promo *'),
              _buildTextField(nameController, 'Nama promo'),
              const SizedBox(height: 20),
              _buildLabel('Kode / Barcode Promo *'),
              _buildTextField(codeController, 'Contoh: PROMO100'),
              const SizedBox(height: 20),
              _buildLabel('Deskripsi'),
              _buildTextField(descController, 'Deskripsi promo', maxLines: 2),
              const SizedBox(height: 20),
              _buildLabel('Kuota Promo (opsional)'),
              _buildTextField(quotaController, 'Contoh: 100', isNumber: true),
              const SizedBox(height: 24),
              _buildLabel('Tipe Promo'),
              Obx(() => Row(
                children: [
                  _buildTypeButton('Diskon', 'diskon', promoType.value == 'diskon', () => promoType.value = 'diskon', LucideIcons.percent, Colors.orange),
                  const SizedBox(width: 8),
                  _buildTypeButton('Bundling', 'bundling', promoType.value == 'bundling', () => promoType.value = 'bundling', LucideIcons.package, Colors.blue),
                ],
              )),
              const SizedBox(height: 24),
              Obx(() => _buildDynamicSection(promoType.value, discountType, valueController, minPurchaseController, bundlingItemsController, freeItemNameController)),
              const SizedBox(height: 24),
              _buildLabel('Periode Promo *'),
              Row(
                children: [
                  Expanded(child: Obx(() => _buildDateField('Dari', startDate.value, () async {
                    DateTime? d = await showDatePicker(context: context, initialDate: startDate.value, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) startDate.value = d;
                  }))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(LucideIcons.arrowRight, size: 14, color: AppColors.slate300)),
                  Expanded(child: Obx(() => _buildDateField('Ke', endDate.value, () async {
                    DateTime? d = await showDatePicker(context: context, initialDate: endDate.value, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (d != null) endDate.value = d;
                  }))),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Validate required fields before sending
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar("Peringatan", "Nama promo wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }
                  if (codeController.text.trim().isEmpty) {
                    Get.snackbar("Peringatan", "Kode promo wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }
                  // Validate value for diskon and bundling types
                  if (valueController.text.trim().isEmpty) {
                    Get.snackbar("Peringatan", "Nilai promo wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }
                  // Validate bundling items for bundling type
                  if (promoType.value == 'bundling' && bundlingItemsController.text.trim().isEmpty) {
                    Get.snackbar("Peringatan", "Isi bundling wajib diisi", backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }

                  final data = {
                    "name": nameController.text.trim(),
                    "code": codeController.text.trim().toUpperCase(),
                    "description": descController.text.trim(),
                    "promo_type": promoType.value,
                    "type": discountType.value,
                    "value": double.tryParse(valueController.text) ?? 0,
                    "min_purchase": double.tryParse(minPurchaseController.text) ?? 0,
                    "bundling_items": bundlingItemsController.text.trim(),
                    "start_date": startDate.value.toIso8601String(),
                    "end_date": endDate.value.toIso8601String(),
                    "is_active": promo?.isActive ?? true,
                    "is_banner": promo?.isBanner ?? false,
                    if (quotaController.text.trim().isNotEmpty)
                      "quota": int.tryParse(quotaController.text.trim()),
                  };
                  
                  final result = promo == null 
                      ? await controller.createPromo(data, imagePath: pickedImagePath.value) 
                      : await controller.updatePromo(promo.id, data, imagePath: pickedImagePath.value);
                  if (result['success']) {
                    Get.back();
                    Get.snackbar("Sukses", "Promo berhasil disimpan", backgroundColor: AppColors.success, colorText: Colors.white);
                  } else {
                    Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: const Text('Simpan Promo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeButton(String label, String value, bool isActive, VoidCallback onTap, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? color : AppColors.slate200),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isActive ? color : AppColors.slate300),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? color : AppColors.slate300)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSection(String promoType, RxString discountType, TextEditingController valueController, TextEditingController minPurchaseController, TextEditingController bundlingController, TextEditingController freeItemController) {
    if (promoType == 'diskon') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Diskon', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.orange)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSmallTypeButton('% Persentase', discountType.value == 'percentage', () => discountType.value = 'percentage', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildSmallTypeButton('Rp Nominal', discountType.value == 'fixed', () => discountType.value = 'fixed', Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Nilai Diskon *'), _buildTextField(valueController, '0', isNumber: true)])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Min. Pembelian'), _buildTextField(minPurchaseController, '0', isNumber: true)])),
              ],
            ),
          ],
        ),
      );
    } else {
      // bundling type
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Bundling', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blue)),
            const SizedBox(height: 16),
            _buildLabel('Isi Bundling *'),
            _buildTextField(bundlingController, 'Contoh: 2 Nasi + 2 Lauk + 2 Minuman'),
            const SizedBox(height: 20),
            _buildLabel('Harga Bundling *'),
            _buildTextField(valueController, 'Rp 0', isNumber: true),
          ],
        ),
      );
    }
  }

  Widget _buildSmallTypeButton(String label, bool isActive, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isActive ? color : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isActive ? color : AppColors.slate200)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? Colors.white : AppColors.slate300))),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      width: double.infinity, height: 160,
      decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.slate100)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.uploadCloud, color: AppColors.slate300, size: 32),
          SizedBox(height: 12),
          Text('Upload Iklan Promo', style: TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold)),
          Text('(JPG, PNG, MP4, Maks. 10MB)', style: TextStyle(color: AppColors.slate200, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate700)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
        filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate100)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.slate100)),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.slate100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate900)),
                const Icon(LucideIcons.calendar, size: 14, color: AppColors.slate300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Promo promo) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus Promo?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: AppColors.slate500, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Kamu akan menghapus promo '),
                    TextSpan(text: '"${promo.name}"', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    const TextSpan(text: '. Tindakan ini tidak dapat diturunkan.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.slate200)),
                      child: const Text('Batal', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await controller.deletePromo(promo.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Promo berhasil dihapus", backgroundColor: AppColors.primary, colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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