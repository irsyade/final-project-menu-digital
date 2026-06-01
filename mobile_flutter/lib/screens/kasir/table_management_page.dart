import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_flutter/constants.dart';
import 'package:mobile_flutter/controllers/table_controller.dart';
import 'package:mobile_flutter/models/table.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  final TableController controller = Get.find<TableController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh data in case it was skipped during unauthenticated startup
    controller.fetchTables();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.slate200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildSearchRow(),
                  const SizedBox(height: 16),
                  _buildTableData(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meja & QR code',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola meja dan QR code untuk pemesanan pelanggan',
                style: TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.slate300),
                ),
                icon: const Icon(LucideIcons.download, size: 16, color: AppColors.slate700),
                label: const Text('Download Semua QR', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddTableDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316), // Orange
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.plus, color: Colors.white, size: 16),
                label: const Text('Tambah Meja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int total = controller.tables.length;
      int aktif = controller.tables.where((t) => t.isActive).length;
      int nonaktif = total - aktif;
      
      return Row(
        children: [
          _buildStatCard('Total Meja', total.toString(), LucideIcons.layoutGrid, Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard('Meja Aktif', aktif.toString(), LucideIcons.checkCircle, Colors.green),
          const SizedBox(width: 16),
          _buildStatCard('Meja Nonaktif', nonaktif.toString(), LucideIcons.xCircle, AppColors.slate400),
          const SizedBox(width: 16),
          _buildStatCard('Total QR Code', total.toString(), LucideIcons.qrCode, Colors.orange),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.slate900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState((){}),
            decoration: InputDecoration(
              hintText: 'Cari meja...',
              hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13, fontWeight: FontWeight.bold),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.slate400),
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Obx(() => Text('${controller.tables.length} meja', style: const TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }

  Widget _buildTableData() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
      }

      var filtered = controller.tables.where((t) {
        return t.number.contains(_searchController.text) || 
               (t.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      }).toList();

      if (filtered.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Tidak ada data meja', style: TextStyle(fontWeight: FontWeight.bold))));
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.slate200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(0.8),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.slate50),
                children: [
                  _th('MEJA'), _th('QR CODE'), _th('TIPE & KAPASITAS'), _th('STATUS'), _th('DIBUAT'), _th('AKSI', align: TextAlign.center),
                ],
              ),
              ...filtered.map((t) => _buildTableRow(t)).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _th(String label, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.slate500, letterSpacing: 1.0),
      ),
    );
  }

  TableRow _buildTableRow(TableModel table) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.slate200)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.slate900, shape: BoxShape.circle),
                child: Center(child: Text(table.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate900, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(table.name ?? 'Meja #${table.number}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.qrCode, color: AppColors.slate700, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scan menu', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 11)),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () => _showQRModal(table),
                    child: const Text('Lihat QR →', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF97316), fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(LucideIcons.layoutGrid, color: AppColors.slate400, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(table.type, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.slate700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('${table.capacity} orang', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Switch(
                value: table.isActive,
                onChanged: (val) => controller.toggleTableActive(table.id, val),
                activeColor: const Color(0xFF10B981),
                inactiveTrackColor: AppColors.slate200,
              ),
              const SizedBox(width: 8),
              Text(
                table.isActive ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 12,
                  color: table.isActive ? const Color(0xFF10B981) : AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Builder(builder: (context) {
            final created = table.createdAt;
            final day = created != null ? DateFormat('d MMM', 'id').format(created) : '-';
            final year = created != null ? DateFormat('yyyy').format(created) : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate500, fontSize: 12)),
                if (year.isNotEmpty)
                  Text(year, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate400, fontSize: 11)),
              ],
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit2, color: Colors.blue, size: 18),
                onPressed: () => _showAddTableDialog(table: table),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                onPressed: () => _confirmDelete(table),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTableDialog({TableModel? table}) {
    final numberController = TextEditingController(text: table?.number ?? "");
    final capacityController = TextEditingController(text: table?.capacity.toString() ?? "4");
    final nameController = TextEditingController(text: table?.name ?? table?.customerName ?? "");
    var isActive = (table?.isActive ?? true).obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(table == null ? 'Tambah Meja Baru' : 'Edit Meja', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(height: 4),
                      const Text('QR code akan dibuat otomatis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate400)),
                    ],
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, color: AppColors.slate400)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nomor Meja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: numberController,
                          decoration: InputDecoration(
                            hintText: 'ex: 5',
                            filled: true, fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kapasitas (orang)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '4',
                            filled: true, fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Nama Meja (opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'VIP, Meja 5, VIP Room 1, Outdoor 1',
                  filled: true, fillColor: AppColors.slate50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Status Meja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate700)),
                      Text('Nonaktifkan jika meja tidak tersedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.slate400)),
                    ],
                  ),
                  Obx(() => Row(
                    children: [
                      Text(isActive.value ? 'Aktif' : 'Nonaktif', style: TextStyle(fontWeight: FontWeight.w900, color: isActive.value ? const Color(0xFF10B981) : AppColors.slate500)),
                      const SizedBox(width: 12),
                      Switch(
                        value: isActive.value,
                        onChanged: (val) => isActive.value = val,
                        activeColor: const Color(0xFF10B981),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.info, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('SIMPANAN: QR code untuk meja ini dapat diakses pada halaman kelola setelah meja disimpan.', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.slate200),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (numberController.text.isEmpty) {
                        Get.snackbar("Error", "Nomor meja wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      
                      final data = {
                        "number": numberController.text,
                        "name": nameController.text.isNotEmpty ? nameController.text : "Meja ${numberController.text}",
                        "type": "Reguler", 
                        "capacity": int.tryParse(capacityController.text) ?? 4,
                        "status": isActive.value ? 'Aktif' : 'Nonaktif',
                        "is_active": isActive.value,
                      };

                      final result = table == null ? await controller.createTable(data) : await controller.updateTable(table.id, data);

                      if (result['success']) {
                        Get.back();
                        Get.snackbar("Sukses", "Data meja berhasil disimpan", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                      } else {
                        Get.snackbar("Gagal", result['message'], backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(table == null ? 'Tambah Meja' : 'Simpan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRModal(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const Text('QR code menu restoran', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(LucideIcons.x, size: 20, color: AppColors.slate400)),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.slate200, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=table_${table.number}', width: 160, height: 160),
              ),
              const SizedBox(height: 16),
              Text('Meja ${table.number}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Text('Scan untuk melihat menu', style: TextStyle(fontSize: 12, color: AppColors.slate400, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildDetailRow('Tipe Meja', table.type),
                    _buildDetailRow('Kapasitas', '${table.capacity} orang'),
                    _buildDetailRow('Status', table.isActive ? 'Aktif' : 'Nonaktif', color: table.isActive ? const Color(0xFF10B981) : AppColors.slate400),
                    _buildDetailRow('Dibuat', '12 Jan 2025'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                      icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
                      label: const Text('Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppColors.slate200)),
                      icon: const Icon(LucideIcons.printer, size: 16, color: AppColors.slate700),
                      label: const Text('Cetak', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900, fontSize: 13)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color ?? AppColors.slate900)),
        ],
      ),
    );
  }

  void _confirmDelete(TableModel table) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.trash2, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              const Text('Hapus Meja?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 12),
              Text('Meja ${table.number} akan dihapus permanen. QR code yang sebelumnya dicetak tidak dapat dipakai kembali.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate500, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppColors.slate200)),
                      child: const Text('Batal', style: TextStyle(color: AppColors.slate700, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await controller.deleteTable(table.id);
                        if (success) {
                          Get.back();
                          Get.snackbar("Sukses", "Meja berhasil dihapus", backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
