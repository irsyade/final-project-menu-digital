import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/models/table.dart';

class AdminTableManagementPage extends StatefulWidget {
  const AdminTableManagementPage({super.key});

  @override
  State<AdminTableManagementPage> createState() => _AdminTableManagementPageState();
}

class _AdminTableManagementPageState extends State<AdminTableManagementPage> {
  final TableController controller = Get.find<TableController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSummaryCards(),
                _buildSearchAndFilters(),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  var filteredTables = controller.tables.where((t) {
                    bool matchesSearch = t.number.contains(_searchController.text) || 
                                         (t.customerName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
                    bool matchesFilter = _selectedFilter == 'Semua' || t.status == _selectedFilter;
                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredTables.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Tidak ada meja.', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold))),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) => _buildTableCard(filteredTables[index]),
                  );
                }),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withOpacity(0.9),
              padding: const EdgeInsets.only(top: 8),
              child: _buildBottomActions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text('Meja & QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900)),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int total = controller.tables.length;
      int aktif = controller.tables.where((t) => t.status == 'Aktif').length;
      int nonaktif = controller.tables.where((t) => t.status == 'Nonaktif').length;
      int booking = controller.tables.where((t) => t.status == 'Booking').length;

      return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = MediaQuery.of(context).size.width > 600;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildSummaryCard('Total Meja', total.toString(), LucideIcons.layoutGrid, Colors.orange, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Aktif', aktif.toString(), LucideIcons.checkCircle2, Colors.green, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Nonaktif', nonaktif.toString(), LucideIcons.xCircle, Colors.red, isTablet),
                const SizedBox(width: 8),
                _buildSummaryCard('Booking', booking.toString(), LucideIcons.calendar, Colors.blue, isTablet),
              ],
            ),
          );
        }
      );
    });
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, bool isTablet) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, size: isTablet ? 14 : 16, color: color),
            const SizedBox(height: 8),
            Text(
              value, 
              style: TextStyle(fontSize: isTablet ? 14 : 16, fontWeight: FontWeight.w900, color: AppColors.slate900),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label, 
              style: TextStyle(fontSize: isTablet ? 7 : 8, color: AppColors.slate400, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nomor pesanan atau meja...',
              hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.slate300),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: ['Semua', 'Aktif', 'Nonaktif', 'Booking'].map((f) {
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
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTableCard(TableModel table) {
    Color statusColor = AppColors.success;
    if (table.status == 'Nonaktif') statusColor = AppColors.slate400;
    if (table.status == 'Booking') statusColor = Colors.orange;

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
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: Center(child: Text(table.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.slate900)),
                    const SizedBox(height: 2),
                    Text('Kapasitas: ${table.capacity} orang', style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(table.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showQRModal(table),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: const Icon(LucideIcons.qrCode, size: 14, color: AppColors.slate900),
                      ),
                      const SizedBox(width: 8),
                      const Text('Lihat QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.download, size: 16, color: AppColors.slate400), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
              const SizedBox(width: 16),
              IconButton(onPressed: () => _showAddTableDialog(table: table), icon: const Icon(LucideIcons.edit, size: 16, color: AppColors.slate400), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
              const SizedBox(width: 16),
              IconButton(onPressed: () => _confirmDelete(table), icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: AppColors.primary),
            ),
            icon: const Icon(LucideIcons.download, size: 16, color: AppColors.primary),
            label: const Text('Download Semua QR (.zip)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAddTableDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
            label: const Text('Tambah Meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showAddTableDialog({TableModel? table}) {
    final numberController = TextEditingController(text: table?.number ?? "");
    final capacityController = TextEditingController(text: table?.capacity?.toString() ?? "");
    final customerNameController = TextEditingController(text: table?.customerName ?? "");
    var selectedStatus = (table?.status ?? 'Aktif').obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(table == null ? 'Tambah Meja' : 'Edit Meja', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Nomor Meja *'), _buildTextField(numberController, '1', isNumber: true)])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Kapasitas *'), _buildTextField(capacityController, '4', isNumber: true, suffix: 'orang')])),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Nama Pemesan (opsional)'),
              _buildTextField(customerNameController, 'Nama orang yang booking meja'),
              const SizedBox(height: 24),
              _buildLabel('Status Meja'),
              Obx(() => Row(
                children: [
                  _buildStatusButton('Aktif', selectedStatus.value == 'Aktif', () => selectedStatus.value = 'Aktif', Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusButton('Nonaktif', selectedStatus.value == 'Nonaktif', () => selectedStatus.value = 'Nonaktif', AppColors.slate400),
                  const SizedBox(width: 8),
                  _buildStatusButton('Booking', selectedStatus.value == 'Booking', () => selectedStatus.value = 'Booking', Colors.orange),
                ],
              )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Setelah menyimpan, QR Code akan digenerate otomatis', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    "number": numberController.text,
                    "capacity": int.tryParse(capacityController.text) ?? 2,
                    "customer_name": customerNameController.text,
                    "status": selectedStatus.value,
                    "type": "Regular",
                    "is_active": selectedStatus.value == 'Aktif',
                  };
                  
                  final result = table == null ? await controller.createTable(data) : await controller.updateTable(table.id, data);
                  if (result['success']) {
                    Get.back();
                    Get.snackbar("Sukses", "Meja berhasil disimpan", backgroundColor: AppColors.success, colorText: Colors.white);
                  } else {
                    Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: const Text('Simpan & Generate QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusButton(String label, bool isActive, VoidCallback onTap, Color color) {
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
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? color : AppColors.slate300))),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate700)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, String? suffix}) {
    return TextField(
      controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13, fontWeight: FontWeight.bold),
        filled: true, fillColor: AppColors.slate50, contentPadding: const EdgeInsets.all(16),
        suffixText: suffix, suffixStyle: const TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _showQRModal(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Text('QR Code Pemesanan', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(24)),
                child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=table_${table.number}', width: 180, height: 180),
              ),
              const SizedBox(height: 16),
              Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const Text('Scan untuk melihat menu', style: TextStyle(fontSize: 10, color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _buildDetailRow('Tipe Meja', table.type),
              _buildDetailRow('Kapasitas', '${table.capacity} orang'),
              _buildDetailRow('Status', table.status, color: table.status == 'Aktif' ? AppColors.success : Colors.orange),
              _buildDetailRow('Dibuat', '12 Jan 2025'),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                      icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
                      label: const Text('Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: AppColors.slate200)),
                      icon: const Icon(LucideIcons.printer, size: 16, color: AppColors.slate700),
                      label: const Text('Cetak', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 12)),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color ?? AppColors.slate900)),
        ],
      ),
    );
  }

  void _confirmDelete(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hapus Meja?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 16),
              const Text('QR code meja ini tidak bisa digunakan lagi setelah dihapus. Tindakan ini tidak dapat diturunkan.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.slate500, fontSize: 13, height: 1.5)),
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
                        bool success = await controller.deleteTable(table.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Meja berhasil dihapus", backgroundColor: AppColors.primary, colorText: Colors.white);
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
